//
//  DocumentNameGenerator.swift
//  SCN
//
//  Created by BAMFAdmin on 17.01.18.
//  Copyright © 2018 BAMFAdmin. All rights reserved.
//

import Foundation
import RealmSwift


class DocumentNameGenerator {
    
    static let realm = RealmService.realm
    
    static func generateDocumentName(changedName: String, isChanged: Bool) {
        
        let existingDocumentInstance = realm.object(ofType: DocumentModel.self, forPrimaryKey: RealmService.getDocumentData().last?.id)

        var documentName = "InvalidQRCode.pdf"
        guard let qrIsValid = RealmService.getQRCode().last?.isValid else {
            return
        }
        if (qrIsValid) {
            documentName = parsingDocumentNameFromQR()
        }
        if isChanged {
            documentName = changedName
            documentName = documentName.replacingOccurrences(of: "/", with: "")
        }
        
        try! realm.write {
            existingDocumentInstance?.documentName = documentName
            realm.add(existingDocumentInstance!, update: true)
        }
    }
    
    static func parsingDocumentNameFromQR() -> String {
        var parsedStudentName = ""
        if RealmService.getQRCode().isEmpty {
            return ""
        } else {
            if RealmService.getQRCode()[0].studentName != nil {
                let studentNameFromQR = RealmService.getQRCode()[0].studentName!
                let parsedStudentNameArray = studentNameFromQR.components(separatedBy: ",")
                var firstInitialName = ""
                if parsedStudentNameArray.count >= 1 {
                    firstInitialName = parsedStudentNameArray[1]
                } else {
                    firstInitialName = parsedStudentNameArray[0]
                }
                let index = firstInitialName.index(firstInitialName.startIndex, offsetBy: 1)
                let firstParsedName = String(describing: firstInitialName[index])
                parsedStudentName = firstParsedName+"."+parsedStudentNameArray[0]
            }
            var parsedStudentId = ""
            if RealmService.getQRCode()[0].studentId != nil {
                let studentIdFromQR = RealmService.getQRCode()[0].studentId!
                parsedStudentId = "_"+studentIdFromQR
            }
            var parsedEventName = ""
            if RealmService.getQRCode()[0].eventName != nil {
                let eventNameFromQR = RealmService.getQRCode()[0].eventName!
                let eventNameWOWhitespaces = eventNameFromQR.removingWhitespaces()
                let parsedEventNameArray = eventNameWOWhitespaces.components(separatedBy: "(")
                parsedEventName = parsedEventNameArray[0]
            }
            var formName = ""
            if RealmService.getQRCode()[0].formName != nil {
                let formNameWithSpaces = RealmService.getQRCode()[0].formName!
                formName = formNameWithSpaces.removingWhitespaces()
            }
            
            var finalPDFName = parsedStudentName + parsedStudentId + parsedEventName + formName+".pdf"
            finalPDFName = finalPDFName.replacingOccurrences(of: "/", with: "")
            return finalPDFName
        }
    }
    
    static func currentDateWithSeconds() -> String {
        let date : Date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy-HH-mm-ss"
        var todaysDate = dateFormatter.string(from: date)
        todaysDate = todaysDate.removingWhitespaces()
        return todaysDate
    }
    
}
