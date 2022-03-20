//
//  EbookRenderModel.swift
//  FolioReaderKit
//
//  Created by Luann Luna on 20/03/22.
//

import Foundation

struct EbookRenderModel: Codable {
    var totalCharacters: Int
    var charactersPerPage = 100
    var charactersPerCap = 1000
    var readedPages: [Int: Set<Int>] = [Int: Set<Int>]()
    var totalPagesPerCap: [Int: Int] = [:]
//    var totalPagesPerCap = [1:1,2:1,3:2,4:21,5:20,6:22,7:21,8:21,9:22,10:20,11:21,12:20,13:21,14:20,15:21,16:19,17:19,18:18,19:24]
    var pages = Set<Int>()
    var relation = [Int: Int]()
    var truePage = Set<Int>()
    
    var caps: Int {
        round(totalCharacters.toDouble / charactersPerCap.toDouble).toInt
    }
    
    var totalPages: Int {
        round(totalCharacters.toDouble / charactersPerPage.toDouble).toInt
    }
    
    var pagesPerCap: Int {
        round(totalPages.toDouble / caps.toDouble).toInt
    }
}
