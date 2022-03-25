//
//  CurrencyConverterTests.swift
//  LeBaluchon
//
//  Created by Dusan Orescanin on 22/03/2022.
//

import XCTest
@testable import LeBaluchon

class CurrencyConverterTests: XCTestCase {
    
    var sut: CurrencyConverter!
    var requestMock: RequestInterfaceMock!
    let apiKeyMock = "1234345"
    
    override func setUp() {
        requestMock = RequestInterfaceMock()
        sut = CurrencyConverter(session: requestMock, apiKey: apiKeyMock)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testInvalidInputCharacter() {
        // Given
        let input = "A"
        let expectation = self.expectation(description: "")
        
        // When
        sut.convert(from: input) { (result) in
            // Then
            XCTAssertEqual(result, .failure(.invalidInput))
            expectation.fulfill()
            
        }
        //wait...
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testInvalidInputDoubleComma() {
        // Given
        let input = "2.."
        let expectation = self.expectation(description: "")
        
        // When
        sut.convert(from: input) { (result) in
            // Then
            XCTAssertEqual(result, .failure(.invalidInput))
            expectation.fulfill()
        }
        //wait...
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testPerformCalculationWithExistingData() {
        // Given
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        let formattedDate = format.string(from: date)
        
        sut.latestRateAndDate = CurrencyConverter.LatestRateAndDate(usdRate: 2.0, requestDate: formattedDate)
        let input = "100,00€"
        let expectation = self.expectation(description: "")
        
        // When
        sut.convert(from: input) { (result) in
            // Then
            XCTAssertEqual(result, .success(200))
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testPerformCalculationWithoutExistingData() {
        // Given
        sut.latestRateAndDate = nil
        let input = "100,00€"
        let expectation = self.expectation(description: "")
        
        requestMock.response = LatestCurrencyResponse(success: true, timestamp: 0, base: "", date: "", rates: ["USD": 2.0])
        
        // When
        sut.convert(from: input) { (result) in
            // Then
            XCTAssertEqual(result, .success(200))
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testInvalidResponseFormat() {
        // Given
        sut.latestRateAndDate = nil
        let input = "100,00€"
        let expectation = self.expectation(description: "")
        
        requestMock.data = Data()
        
        // When
        sut.convert(from: input) { (result) in
            // Then
            XCTAssertEqual(result, .failure(.invalidResponseFormat))
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testRequestsDataIfTheresNoDataAndInputIsValid() {
        // Given
        sut.latestRateAndDate = nil
        let input = "100,00€"
        
        // When
        sut.convert(from: input) {_ in}
        
        //Then
        XCTAssertEqual(self.requestMock.request?.httpMethod, "GET")
        
        let url = requestMock.request?.url?.absoluteString
        let urlComponents = URLComponents(string: url!)
        
        XCTAssertEqual(urlComponents?.scheme, "http")
        XCTAssertEqual(urlComponents?.host, "data.fixer.io")
        XCTAssertEqual(urlComponents?.path, "/api/latest")
        XCTAssertEqual(urlComponents?.queryItems?[0], URLQueryItem(name: "access_key", value: apiKeyMock))
        XCTAssertEqual(urlComponents?.queryItems?[1], URLQueryItem(name: "base", value: "eur"))
        XCTAssertEqual(urlComponents?.queryItems?[2], URLQueryItem(name: "symbols", value: "usd"))
    }
    
    func testRequestError() {
        // Given
        let error = NSError(domain: "", code: 0, userInfo: nil)
        sut.latestRateAndDate = nil
        let input = "100,00€"
        let expectation = self.expectation(description: "")
        
        requestMock.error = error
        
        // When
        sut.convert(from: input) { (result) in
            // Then
            XCTAssertEqual(result, .failure(.requestError(error)))
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testUsdRateNotFound() {
        // Given
        sut.latestRateAndDate = nil
        let input = "100,00€"
        let expectation = self.expectation(description: "")
        
        requestMock.response = LatestCurrencyResponse(success: true, timestamp: 0, base: "", date: "", rates: ["": 2.0])
        
        // When
        sut.convert(from: input) { (result) in
            // Then
            XCTAssertEqual(result, .failure(.usdRateNotFound))
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
}


extension CurrencyConverterTests {
    
    final class RequestInterfaceMock: RequestInterface {
        
        var request: URLRequest?
        
        var response: LatestCurrencyResponse?
        
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
