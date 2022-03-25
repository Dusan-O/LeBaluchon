//
//  WeatherTests.swift
//  LeBaluchon
//
//  Created by Dusan Orescanin on 22/03/2022.
//

import XCTest
@testable import LeBaluchon

class WeatherTest: XCTestCase {
    
    var sut: Weather!
    var requestMock: RequestInterfaceMock!
    let apiKeyMock = "1234345"
    
    override func setUp() {
        requestMock = RequestInterfaceMock()
        sut = Weather(session: requestMock, apiKey: apiKeyMock)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testFrenchTranslation() {
        // Given
        let expectation = self.expectation(description: "")
        
        let mainResponse = MainResponse(temp: 20, humidity: 10, temp_min: 2, temp_max: 21)
        let descriptionResponse = DescriptionResponse(description: "Pluvieux")
        let response = LatestWeatherResponse(main: mainResponse, weather: [descriptionResponse], dt: 122344556)
        requestMock.response = response
        
        // When
        sut.request(from: 0, then: { (result) in
            // Then
            XCTAssertEqual(result, .success(response))
            expectation.fulfill()
        })
        //wait...
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testRequestError() {
        // Given
        let error = NSError(domain: "", code: 0, userInfo: nil)
        let expectation = self.expectation(description: "")
        
        requestMock.error = error
        
        // When
        sut.request(from: 0) { (result) in
            // Then
            XCTAssertEqual(result, .failure(.requestError(error)))
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testInvalidResponseFormat() {
        // Given
        let expectation = self.expectation(description: "")
        
        requestMock.data = Data()
        
        // When
        sut.request(from: 0) { (result) in
            // Then
            XCTAssertEqual(result, .failure(.invalidResponseFormat))
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testRequestsData() {
        // Given
        let mainResponse = MainResponse(temp: 20, humidity: 10, temp_min: 2, temp_max: 21)
        let descriptionResponse = DescriptionResponse(description: "Pluvieux")
        requestMock.response = LatestWeatherResponse(main: mainResponse, weather: [descriptionResponse], dt: 122344556)
        
        // When
        sut.request(from: 0) {_ in}
        
        //Then
        XCTAssertEqual(self.requestMock.request?.httpMethod, "GET")
        
        let url = requestMock.request?.url?.absoluteString
        let urlComponents = URLComponents(string: url!)
        
        XCTAssertEqual(urlComponents?.scheme, "https")
        XCTAssertEqual(urlComponents?.host, "api.openweathermap.org")
        XCTAssertEqual(urlComponents?.path, "/data/2.5/weather")
        XCTAssertEqual(urlComponents?.queryItems?[0], URLQueryItem(name: "q", value: "paris,fr"))
        XCTAssertEqual(urlComponents?.queryItems?[1], URLQueryItem(name: "mode", value: "json"))
        XCTAssertEqual(urlComponents?.queryItems?[2], URLQueryItem(name: "lang", value: "fr"))
        XCTAssertEqual(urlComponents?.queryItems?[3], URLQueryItem(name: "units", value: "metric"))
        XCTAssertEqual(urlComponents?.queryItems?[4], URLQueryItem(name: "APPID", value: apiKeyMock))
    }
    
    func testIndexZeroRequestsParisWeatherInfo() {
        // Given
        let index = 0
        
        // When
        sut.request(from: index) {_ in}
        
        // Then
        let url = requestMock.request?.url?.absoluteString
        let urlComponents = URLComponents(string: url!)
        XCTAssertEqual(urlComponents?.queryItems?[0], URLQueryItem(name: "q", value: "paris,fr"))
    }
    
    func testIndexOneRequestsNewYorkWeatherInfo() {
        // Given
        let index = 1
        
        // When
        sut.request(from: index) {_ in}
        
        // Then
        let url = requestMock.request?.url?.absoluteString
        let urlComponents = URLComponents(string: url!)
        XCTAssertEqual(urlComponents?.queryItems?[0], URLQueryItem(name: "q", value: "new york,us"))
    }
    
    func testByDefaultRequestsParisWeatherInfo() {
        // Given
        for i in 2...100 {
            
            // When
            sut.request(from: i) {_ in}
            
            // Then
            let url = requestMock.request?.url?.absoluteString
            let urlComponents = URLComponents(string: url!)
            XCTAssertEqual(urlComponents?.queryItems?[0], URLQueryItem(name: "q", value: "paris,fr"))
        }
    }
}

extension WeatherTest {
    
    final class RequestInterfaceMock: RequestInterface {
        
        var request: URLRequest?
        
        var response: LatestWeatherResponse?
        
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
