//
//  ExcludesFileReaderTests.swift
//  ExcludesFileReaderTests
//
//  Created by Simion Schiopu on 11/19/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Quick
import Nimble
@testable import ExcludesFileReader

let TestFileName = "excludes"
let TestFileExtension = "yml"
let DefaultExcludesFile = "/excludes.yml"
let WrongExcludesFile = "wrongType.yl"

class ExcludesFileReaderTests: QuickSpec {
    
    override func spec() {
        describe("Excludes File Reader") {
            var fileManager: MockFileManager!
            var excludesFileReader: ExcludesFileReader!
            var testFilePath: String!
            var analyzePath: String!
            
            beforeEach {
                fileManager = MockFileManager()
                excludesFileReader = ExcludesFileReader(fileManager:fileManager)
                testFilePath = fileManager.testFile(TestFileName, fileType: TestFileExtension)
                analyzePath = testFilePath.replacingOccurrences(of: DefaultExcludesFile, with: "")
            }
            
            afterEach {
                excludesFileReader = nil
                fileManager = nil
                
            }
            
            it("should throw exception if file does not exists at path") {
                expect {
                    try excludesFileReader.absolutePathsFromExcludesFile(DefaultExcludesFile, forAnalyzePath: analyzePath)
                    }.to(throwError(CommandLineError.excludesFileError("")))
            }
            
            it("should throw exception if file exists but it is directory") {
                expect {
                    try excludesFileReader.absolutePathsFromExcludesFile(DefaultExcludesFile, forAnalyzePath: analyzePath)
                    }.to(throwError())
            }
            
            it("should throw exception if file exists but is not of extension .yml") {
                let wrongType = fileManager.testFile(TestFileName, fileType: "yl")
                expect {
                    try excludesFileReader.absolutePathsFromExcludesFile(wrongType, forAnalyzePath: analyzePath)
                    }.to(throwError())
            }
            
            it("shouldn't throw exception for existing file with .yml extension") {
                expect {
                    try excludesFileReader.absolutePathsFromExcludesFile(testFilePath, forAnalyzePath: analyzePath)
                    }.toNot(throwError())
            }
            
            it("shouldn't throw exception for test yml file") {
                testFilePath = fileManager.testFile(TestFileName, fileType: TestFileExtension)
                expect {
                    try excludesFileReader.absolutePathsFromExcludesFile(testFilePath, forAnalyzePath: analyzePath)
                    }.toNot(throwError())
            }
            
            it("should return an empty array for empty file") {
                expect{
                    try excludesFileReader.absolutePathsFromExcludesFile(analyzePath + "/emptyExcludes.yml", forAnalyzePath: analyzePath)
                    }.to(equal([]))
            }
            
            it("should return an array of absolute paths excluding files with ** prefix") {
                let resultsArray = ["/root/project/folderTests/testfile.txt", "/root/project/folderTests/testfile2.txt", "/root/file.txt", "/root/path/to/file.txt", "/root/folder", "/root/path/to/folder"]
                expect {
                    try excludesFileReader.absolutePathsFromExcludesFile(testFilePath, forAnalyzePath: "/root")
                    }.to(equal(resultsArray))
            }
            
            it("should throw error if path to directory was passed") {
                expect {
                    try excludesFileReader.absolutePathsFromExcludesFile("pathToDirectory", forAnalyzePath: "")
                    }.to(throwError())
            }
            
            it("should throw error if path to file with another extension was passed") {
                expect {
                    try excludesFileReader.absolutePathsFromExcludesFile("pathToFile.txt", forAnalyzePath: "")
                    }.to(throwError())
            }
            
        }
    }
}
