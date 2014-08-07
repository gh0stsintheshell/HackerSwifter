//
//  CacheTests.swift
//  HackerSwifter
//
//  Created by Thomas Ricouard on 16/07/14.
//  Copyright (c) 2014 Thomas Ricouard. All rights reserved.
//

import XCTest
import HackerSwifter

class CacheTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    func pathtest() {
        var path = "test/test?test/test"
        var result = "test#test?test#test"
        
        XCTAssertTrue(DiskCache.generateCacheKey(path) == result, "cache key is not equal to result")
    }
    
    func testMemoryCache() {
        var post = Post()
        post.title = "Test"
        
        MemoryCache.sharedMemoryCache.setObject(post, key: "post")
        
        var postTest = MemoryCache.sharedMemoryCache.objectForKeySync("post") as Post
    
        XCTAssertNotNil(postTest, "Post is nil")
        XCTAssertTrue(postTest.isKindOfClass(Post), "Post is not kind of class post")
        XCTAssertTrue(postTest.title == "Test", "Post title is not equal to prior test")
        
        MemoryCache.sharedMemoryCache.removeObject("post")
        
        XCTAssertNil(MemoryCache.sharedMemoryCache.objectForKeySync("post"), "post should be nil")
    }
    
    func testDiskCache() {
        var expectation = self.expectationWithDescription("write disk cache")
        
        var post = Post()
        post.title = "Test"
      
        DiskCache.sharedDiskCache.setObject(post, key: "post")
        
        let delay = 1.0 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            var postTest = DiskCache.sharedDiskCache.objectForKeySync("post") as Post
            
            XCTAssertNotNil(postTest, "Post is nil")
            XCTAssertTrue(postTest.isKindOfClass(Post), "Post is not kind of class post")
            XCTAssertTrue(postTest.title == "Test", "Post title is not equal to prior test")
            
            DiskCache.sharedDiskCache.removeObject("post")
            
            XCTAssertNil(DiskCache.sharedDiskCache.objectForKeySync("post"), "post should be nil")
            expectation.fulfill()
        })
        self.waitForExpectationsWithTimeout(2.0, handler: nil)
    }
    
    func testGlobalCache() {
        var expectation = self.expectationWithDescription("write global cache")
        var post = Post()
        post.title = "Global Test"
            
        Cache.sharedCache.setObject(post, key: "post")
        let delay = 1.0 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            var globalPost = Cache.sharedCache.objectForKeySync("post") as Post
            var memoryPost = MemoryCache.sharedMemoryCache.objectForKeySync("post") as Post
            var diskPost = DiskCache.sharedDiskCache.objectForKeySync("post") as Post
            
            XCTAssertNotNil(globalPost, "Global Post is nil")
            XCTAssertNotNil(memoryPost, "Memory Post is nil")
            XCTAssertNotNil(diskPost, "Dissk Post is nil")
            
            XCTAssertTrue(globalPost.isKindOfClass(Post), "Global Post is not kind of class post")
            XCTAssertTrue(globalPost.title == "Global Test", "Global Post title is not equal to prior test")
            
            XCTAssertTrue(memoryPost.isKindOfClass(Post), "Memory Post is not kind of class post")
            XCTAssertTrue(memoryPost.title == "Global Test", "Memory Post title is not equal to prior test")
            
            XCTAssertTrue(diskPost.isKindOfClass(Post), "Disk Post is not kind of class post")
            XCTAssertTrue(diskPost.title == "Global Test", "Disk Post title is not equal to prior test")
            
            Cache.sharedCache.removeObject("post")
            
            XCTAssertNil(Cache.sharedCache.objectForKeySync("post"), "post should be nil")
            XCTAssertNil(MemoryCache.sharedMemoryCache.objectForKeySync("post"), "post should be nil")
            XCTAssertNil(DiskCache.sharedDiskCache.objectForKeySync("post"), "post should be nil")
            expectation.fulfill()
        })
        self.waitForExpectationsWithTimeout(2.0, handler: nil)
    }
    
}
