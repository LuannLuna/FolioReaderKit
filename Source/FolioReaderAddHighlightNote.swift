//
//  FolioReaderAddHighlightNote.swift
//  FolioReaderKit
//
//  Created by ShuichiNagao on 2018/05/06.
//

import UIKit
import RealmSwift
import SnapKit

class FolioReaderAddHighlightNote: UIViewController {

    private lazy var textView = UITextView().with {
        $0.delegate = self
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .black
        $0.backgroundColor = .white
        $0.font = UIFont.boldSystemFont(ofSize: 15)
    }

    private lazy var highlightLabel = UILabel().with {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.numberOfLines = 3
        $0.font = UIFont.systemFont(ofSize: 15)
    }

    private lazy var scrollView = UIScrollView().with {
        $0.bounces = false
    }

    private lazy var containerView = UIView().with {
        $0.backgroundColor = .white
    }

    private var highlight: Highlight
    private lazy var highlightSaved = false
    lazy var isEditHighlight = false
    private lazy var resizedTextView = false
    
    private var folioReader: FolioReader
    private var readerConfig: FolioReaderConfig
    
    init(withHighlight highlight: Highlight, folioReader: FolioReader, readerConfig: FolioReaderConfig) {
        self.folioReader = folioReader
        self.highlight = highlight
        self.readerConfig = readerConfig
        
        super.init(nibName: nil, bundle: Bundle.frameworkBundle())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    // MARK: - life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupTextView()
        setCloseButton(withConfiguration: readerConfig)
        configureNavBar()
        configureKeyboardObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        containerView.frame = view.bounds
        scrollView.contentSize = view.bounds.size
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if !highlightSaved && !isEditHighlight {
            guard let currentPage = folioReader.readerCenter?.currentPage else { return }
            currentPage.webView?.js("removeThisHighlight()")
        }
    }
    
    // MARK: - private methods

    private func setupTextView() {
        highlightLabel.text = highlight.content.stripHtml().truncate(250, trailing: "...").stripLineBreaks()
    }
    
    private func configureNavBar() {
        let tintColor = readerConfig.tintColor
        if let font = UIFont(name: "Avenir-Light", size: 17) {
            let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: tintColor]
            UIBarButtonItem.appearance().setTitleTextAttributes(attributes, for: .normal)
        }

        let saveButton = UIBarButtonItem(title: readerConfig.localizedSave,
                                         style: .plain,
                                         target: self,
                                         action: #selector(saveNote(_:)))
        navigationItem.rightBarButtonItem = saveButton
    }
    
    private func configureKeyboardObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification){
        guard let userInfo = notification.userInfo else { return }
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        self.scrollView.contentInset = contentInset
    }
    
    @objc private func keyboardWillHide(notification:NSNotification) {
        let contentInset: UIEdgeInsets = .zero
        self.scrollView.contentInset = contentInset
    }
    
    @objc private func saveNote(_ sender: UIBarButtonItem) {
        if !textView.text.isEmpty {
            if isEditHighlight {
                if let realm = try? Realm(configuration: readerConfig.realmConfiguration) {
                    realm.beginWrite()
                    highlight.noteForHighlight = textView.text
                    highlightSaved = true
                    try? realm.commitWrite()
                }
            } else {
                highlight.noteForHighlight = textView.text
                highlight.persist(withConfiguration: readerConfig)
                highlightSaved = true
            }
        }
        dismiss()
    }
}

// MARK: - UITextViewDelegate
extension FolioReaderAddHighlightNote: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height + 15)
        textView.frame = newFrame;
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }
}


extension FolioReaderAddHighlightNote: ViewCodable {
    func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(textView)
        containerView.addSubview(highlightLabel)

        #warning("delete this 2 lines")
        containerView.backgroundColor = .black
        textView.backgroundColor = .yellow
    }

    func setupAnchors() {
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        textView.snp.makeConstraints { $0.edges.equalToSuperview().inset(20) }

        highlightLabel.snp.makeConstraints { make in
            make.left.equalTo(containerView).inset(20)
            make.right.equalTo(containerView).inset(-20)
            make.top.equalTo(containerView).inset(50)
            make.height.equalTo(70)
        }
    }
}
