//
//  SaveTrackViewController.swift
//  TinyMVVMDemo
//
//  Created by Aleksei Artamonov on 5/2/19.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit

class SaveTrackViewController: BaseViewController {

    public var viewModel: SaveTrackViewModeling? {
        didSet {
            guard let viewModel = viewModel else {
                return
            }
            
            viewModel.trackName.addListener { [weak self] (value) in
                guard self?.isViewLoaded ?? false else {
                    return
                }
                self?.trackNameTextField.text = value
            }
            
            viewModel.trackNote.addListener { [weak self] (value) in
                guard self?.isViewLoaded ?? false else {
                    return
                }
                self?.notesTextView.text = value
            }
        }
    }
    
    public var router: SaveTrackRouting?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var trackNameTextField: UITextField!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        notesTextView.delegate = self
        trackNameTextField.delegate = self
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func handleSaveButtonTap(_ sender: Any) {
        view.endEditing(true)
        viewModel?.saveTrack { (success) in
            if !success {
                print("Saving Error...")
            } else {
                self.router?.close()
            }
        }
    }
    
    @IBAction func handleCancelButtonTap(_ sender: Any) {
        router?.close()
    }
    
}

extension SaveTrackViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        viewModel?.trackName.value = textField.text ?? ""
    }
}

extension SaveTrackViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        viewModel?.trackNote.value = textView.text
    }
}
