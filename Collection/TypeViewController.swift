//
//  TypeViewController.swift
//  ThoughtCloud
//
//  Created by Jason Ono on 7/27/20.
//  Copyright © 2020 Jason Ono. All rights reserved.
//

import UIKit
import CoreData
import NaturalLanguage


class TypeViewController: UIViewController{

// MARK: - Root methods/variables
    
    // root helper variables
    let windowSize: CGRect = UIScreen.main.bounds
    let windowWidth: CGFloat = UIScreen.main.bounds.width
    let windowHeight: CGFloat = UIScreen.main.bounds.height
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = UIView(frame: self.view.bounds)
        view.backgroundColor = UIColor.white
        
        // UI
        createScrollView()
        createTitleView()
        createTextView()
        setupLayout()
        customizeNavigationBar()
        self.setupToHideKeyboardOnTapOnView()
    }

// MARK: - UI Components
    
    /*
     titleView and textInputView are subviews of contentView, which in itself is a part of scrollView. titleView expands itself dynamically depending on the size of the content, and the views that contain titleView support the change in size.
     */
    
    // variables
    var scrollView = UIScrollView()
    var contentView = UIView()
    var titleView = UITextView()
    var textInputView = UITextView()
    
    func createScrollView(){
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.showsVerticalScrollIndicator = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.isUserInteractionEnabled = true
    }
    
    func createTitleView(){
        contentView.addSubview(titleView)   // add titleView -> contentView
        // content setup
        titleView.backgroundColor = .systemGray4
        titleView.delegate = self
        titleView.text = cc.title
        titleView.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        titleView.backgroundColor = .white
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.isScrollEnabled = false
    }
    
    func createTextView(){
        contentView.addSubview(textInputView)   // add titleView -> contentView
        // content setup
        textInputView.backgroundColor = .systemGray2
        textInputView.delegate = self
        textInputView.text = cc.text
        textInputView.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        textInputView.backgroundColor = .white
        textInputView.translatesAutoresizingMaskIntoConstraints = false
        textInputView.isScrollEnabled = false
    }
    
    func setupLayout(){
        [scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
         scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
         scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: windowWidth*0.01),
         scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
         scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -windowWidth*0.01),
        ].forEach{ $0.isActive = true }
        
        [contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
         contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
         contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
         contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
         contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ].forEach{ $0.isActive = true }
        
        [titleView.topAnchor.constraint(equalTo: contentView.topAnchor),
         titleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
         titleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
         titleView.widthAnchor.constraint(equalTo: contentView.widthAnchor)
        ].forEach{ $0.isActive = true }

        [textInputView.topAnchor.constraint(equalTo: titleView.bottomAnchor),
         textInputView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
         textInputView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
         textInputView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
         textInputView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ].forEach { $0.isActive = true }
        
    }
    // MARK: - Navigation Bar methods
    
    // the "share" icon pushes a new VC for the tag cloud.
    func customizeNavigationBar(){
        navigationItem.title = "Notebook"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(addTapped(_:)))
    }
    
    @objc func addTapped(_ sender: UIBarButtonItem){
        // if the text input was fewer than 20 words, new VC does not get pushed.
        if (processText(cc.text ?? "").count < 20){
            let alert = UIAlertController(title: "Type more text.", message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel) { (action) in }
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }else{
            // Otherwise, new VC is pushed.
            saveCC()
            let sphereVC = SphereViewController()
            // sends the text information to the next VC.
            sphereVC.passCC(ccArray[indexPathRow], indexPathRow)
            navigationController?.pushViewController(sphereVC, animated: true)
        }
    }
    /*
        In this VC, this method is called only to measure the number of words of interest.
     */
    func processText(_ text: String)->[CloudWord]{
        // initiate an empty CloudWord array
        var cloudWordArray: [CloudWord] = []
        let relevantType: [NLTag] = [NLTag.adjective, NLTag.noun]
        // prep for NL process
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = text
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace]
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange in
            if let tag = tag {
                
                // checker Int and individual word
                var checker: Int = 0
                let theTag: String = String(text[tokenRange])
                
                // duplicate check
                for i in 0..<(cloudWordArray.count){
                    if cloudWordArray[i].word == theTag{
                        cloudWordArray[i].increNumOfTimes()
                        checker+=1
                    }
                }
                
                // create and add to the array only when the word is new and the type is relevant
                if (checker==0 && relevantType.contains(NLTag(rawValue: tag.rawValue)) == true){
                    let newCloudWord = CloudWord(theTag, NLTag(rawValue: tag.rawValue))
                    cloudWordArray.append(newCloudWord)
                }
            }
            return true
        }
        cloudWordArray.sort()
        cloudWordArray.reverse()
        return cloudWordArray
    }
    
    
    // MARK: - CoreData methods
    
    // variables
    var ccArray = [CloudCollection()]
    var cc = CloudCollection()
    var indexPathRow = 0
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func saveCC(){
        cc.dateLastUpdated = Date()
        cc.title = titleView.text
        cc.text = textInputView.text
        ccArray[indexPathRow] = cc
        do{
            try context.save()
        }catch{
            print("error")
        }
    }
    
    func reloadData(){
        DispatchQueue.main.async{
            self.titleView.text = self.cc.title
            self.textInputView.text = self.cc.text
        }
    }
}

// MARK: - TextView methods
extension TypeViewController: UITextViewDelegate{
    
    // Ensures that the change in the TextView is saved each time there is a change
    func textViewDidEndEditing(_ textView: UITextView) {
        saveCC()
    }
}

// Allows users to dissmiss the keyboard by touching the non-keyboard region of the display
// Written by Matthew Bradshaw on stackoverflow: https://tinyurl.com/y5jv3r6d
extension UIViewController
{
    func setupToHideKeyboardOnTapOnView()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))

        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}
