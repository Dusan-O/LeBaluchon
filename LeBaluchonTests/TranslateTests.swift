//
//  TranslateTests.swift
//  LeBaluchon
//
//  Created by Dusan Orescanin on 24/03/2022.
//

import XCTest
@testable import LeBaluchon

class TranslateTest: XCTestCase {
    
    var sut: Translation!
    var requestMock: RequestInterfaceMock!
    let apiKeyMock = "1234345"
    
    override func setUp() {
        requestMock = RequestInterfaceMock()
        sut = Translation(session: requestMock, apiKey: apiKeyMock)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testFrenchTranslation() {
        // Given
        let input = "Bonjour"
        let expectation = self.expectation(description: "")
        
        let dataResponse = DataResponse(translations: [TranslatedTextResponse(translatedText: "Hello")])
        requestMock.response = LatestTranslationResponse(data: dataResponse)
        
        // When
        sut.request(from: input, then: { (result) in
            // Then
            XCTAssertEqual(result, .success("Hello"))
            expectation.fulfill()
        })
        //wait...
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testSpanishTranslation() {
        // Given
        let input = "Hola"
        let expectation = self.expectation(description: "")
        
        let dataResponse = DataResponse(translations: [TranslatedTextResponse(translatedText: "Hi")])
        requestMock.response = LatestTranslationResponse(data: dataResponse)
        
        // When
        sut.request(from: input, then: { (result) in
            // Then
            XCTAssertEqual(result, .success("Hi"))
            expectation.fulfill()
        })
        //wait...
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testRequestError() {
                // Given
           let error = NSError(domain: "", code: 0, userInfo: nil)
           let input = "Bonjours"
           let expectation = self.expectation(description: "")
           
           requestMock.error = error
           
           // When
           sut.request(from: input) { (result) in
               // Then
               XCTAssertEqual(result, .failure(.requestError(error)))
               expectation.fulfill()
           }
           waitForExpectations(timeout: 1, handler: nil)
       }
       
    func testInvalidResponseFormat() {
        // Given
        let input = "Bonjour"
        let expectation = self.expectation(description: "")
        
        requestMock.data = Data()

        // When
        sut.request(from: input) { (result) in
             // Then
            XCTAssertEqual(result, .failure(.invalidResponseFormat))
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testInvalidResponseFormatIfNoTranslationsInArray() {
        // Given
        let input = "Hola"
        let expectation = self.expectation(description: "")
        
        let dataResponse = DataResponse(translations: [])
        requestMock.response = LatestTranslationResponse(data: dataResponse)
        
        // When
        sut.request(from: input, then: { (result) in
            // Then
            XCTAssertEqual(result, .failure(.invalidResponseFormat))
            expectation.fulfill()
        })
        //wait...
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testRequestsData() {
        // Given
        let input = "Bonjour"
        let dataResponse = DataResponse(translations: [TranslatedTextResponse(translatedText: "Hi")])
        
        requestMock.response = LatestTranslationResponse(data: dataResponse)
        // When
        sut.request(from: input) {_ in}
        
        //Then
        XCTAssertEqual(self.requestMock.request?.httpMethod, "POST")
        
        let url = requestMock.request?.url?.absoluteString
        let urlComponents = URLComponents(string: url!)
        
        XCTAssertEqual(urlComponents?.scheme, "https")
        XCTAssertEqual(urlComponents?.host, "translation.googleapis.com")
        XCTAssertEqual(urlComponents?.path, "/language/translate/v2")
        XCTAssertEqual(urlComponents?.queryItems?[0], URLQueryItem(name: "q", value: input))
        XCTAssertEqual(urlComponents?.queryItems?[1], URLQueryItem(name: "target", value: "en"))
        XCTAssertEqual(urlComponents?.queryItems?[2], URLQueryItem(name: "format", value: "text"))
        XCTAssertEqual(urlComponents?.queryItems?[3], URLQueryItem(name: "key", value: apiKeyMock))
    }
    
    
}

extension TranslateTest {
    
    final class RequestInterfaceMock: RequestInterface {
        
        var request: URLRequest?
        
        var response: LatestTranslationResponse?
        
        var error: Error?
        
        var data: Data?
        
        func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            self.request = request
            
            if let response = response {
                let data = try! JSONEncoder().encode(response)
                completionHandler(data, nil, nil)
                
            } else {
                completionHandler(data, nil, error)
            }
            
            if #available(iOS 13, *) {
                return URLSession.shared.dataTask(with: request)
            } else {
                return URLSessionDataTask()
            }
        }
    }
}
