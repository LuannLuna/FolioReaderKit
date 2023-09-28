//
//  ViewController.swift
//  Example
//
//  Created by Heberti Almeida on 08/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit
import FolioReaderKit

class ViewController: UIViewController {

    @IBOutlet weak var bookOne: UIButton?
    @IBOutlet weak var bookTwo: UIButton?
    let folioReader = FolioReader()
    
    
    var readingPercentage: [Int: [Int]] = [:]
    var currentCap: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.bookOne?.tag = Epub.bookOne.rawValue
        self.bookTwo?.tag = Epub.bookTwo.rawValue

        self.setCover(self.bookOne, index: 0)
        self.setCover(self.bookTwo, index: 1)
    }

    private func readerConfiguration(forEpub epub: Epub) -> FolioReaderConfig {
        let config = FolioReaderConfig(withIdentifier: epub.readerIdentifier)
        config.shouldHideNavigationOnTap = epub.shouldHideNavigationOnTap
        config.scrollDirection = epub.scrollDirection
        config.hideScrollScrubber = true
        // See more at FolioReaderConfig.swift
//        config.canChangeScrollDirection = false
//        config.enableTTS = false
//        config.displayTitle = true
//        config.allowSharing = false
//        config.tintColor = UIColor.blueColor()
//        config.toolBarTintColor = UIColor.redColor()
//        config.toolBarBackgroundColor = UIColor.purpleColor()
//        config.menuTextColor = UIColor.brownColor()
//        config.menuBackgroundColor = UIColor.lightGrayColor()
//        config.hidePageIndicator = true
//        config.realmConfiguration = Realm.Configuration(fileURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("highlights.realm"))

        // Custom sharing quote background
        config.quoteCustomBackgrounds = []
        if let image = UIImage(named: "demo-bg") {
            let customImageQuote = QuoteImage(withImage: image, alpha: 0.6, backgroundColor: UIColor.black)
            config.quoteCustomBackgrounds.append(customImageQuote)
        }

        let textColor = UIColor(red:0.86, green:0.73, blue:0.70, alpha:1.0)
        let customColor = UIColor(red:0.30, green:0.26, blue:0.20, alpha:1.0)
        let customQuote = QuoteImage(withColor: customColor, alpha: 1.0, textColor: textColor)
        config.quoteCustomBackgrounds.append(customQuote)

        return config
    }

    fileprivate func open(epub: Epub) {
        guard let bookPath = epub.bookPath else {
            return
        }

        let readerConfiguration = self.readerConfiguration(forEpub: epub)
        folioReader.delegate = self
        folioReader.presentReader(parentViewController: self, withEpubPath: bookPath, andConfig: readerConfiguration, shouldRemoveEpub: false)
        folioReader.readerCenter?.delegate = self
        folioReader.readerCenter?.pageDelegate = self
        folioReader.readerContainer?.centerViewController?.pageIndicatorView?.delegate = self
    }

    private func setCover(_ button: UIButton?, index: Int) {
        guard
            let epub = Epub(rawValue: index),
            let bookPath = epub.bookPath else {
                return
        }

        do {
            let image = try FolioReader.getCoverImage(bookPath)

            button?.setBackgroundImage(image, for: .normal)
        } catch {
            print(error.localizedDescription)
        }
    }
}
extension ViewController: FolioReaderPageIndicatorDelegate {
    func pageScrolled(currentPage: Int, totalPages: Int) {
        guard let cap = folioReader.readerContainer?.centerViewController?.currentPage?.pageNumber else { return }
        if totalPages != 0 {
            let percent = (100 * currentPage) / totalPages
            guard var readed = readingPercentage[cap] else {
                readingPercentage[cap] = [percent]
                return
            }
            readed.append(percent)
            readingPercentage[cap] = readed
        }
    }
}

extension ViewController: FolioReaderPageDelegate {
    func pageDidLoad(_ page: FolioReaderPage) {
//        print("*** pageDidLoad")
//        print("**** PageNumber: \(page.pageNumber)") // Número do captulo
    }
}

extension ViewController: FolioReaderCenterDelegate {
    func pageDidAppear(_ page: FolioReaderPage) {
//        print("*** pageDidAppear")
//        print("**** PageNumber: \(page.pageNumber)") // Número do captulo
    }
    
}

extension ViewController: FolioReaderDelegate {
    func folioReader(_ folioReader: FolioReader, didFinishedLoading book: FRBook) {
//        print("*** didFinishedLoading")
//        print("**** CurrentPage: \(folioReader.readerCenter!.currentPage)")
//        folioReader.readerCenter?.pageIndicatorView?.currentPage
    }
    
    func folioReaderScrollPage(_ folioReader: FolioReader) {
//        print("**** CurrentPageScroll: \(folioReader.readerCenter!.pageIndicatorView?.currentPage)")
//        print("*** ReaderScrollPage")
        folioReader.readerCenter?.getCurrentPageItemNumber()
    }
    
    func renderDidClose() {
        print("*** Radeing: \(readingPercentage)")
        
    }
}

extension ViewController {
    
    @IBAction func didOpen(_ sender: AnyObject) {
        guard let epub = Epub(rawValue: sender.tag) else {
            return
        }

        self.open(epub: epub)
    }
}
