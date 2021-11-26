//
//  ViewController.swift
//  PHPickerExample
//
//  Created by Aris Koxaras on 26/11/21.
//

import UIKit
import PhotosUI
import AVKit
import AVFoundation

class ViewController: UIViewController, PHPickerViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = PHPickerFilter.videos

        let pickerViewController = PHPickerViewController(configuration: config)
        pickerViewController.delegate = self
        self.present(pickerViewController, animated: true, completion: nil)


    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)

        for result in results {
            debugPrint("checking was \(result.itemProvider.description)")

            if result.itemProvider.hasItemConformingToTypeIdentifier("public.movie") {

                result.itemProvider.loadFileRepresentation(forTypeIdentifier: "public.movie") { videoURL, error in

                    assert(Thread.isMainThread == false)

                    let directory = NSTemporaryDirectory()
                    let fileName = NSUUID().uuidString.appending(".mov")

                    if let videoURL = videoURL,
                       let copiedURLFile = NSURL.fileURL(withPathComponents: [directory, fileName]) {
                        try! FileManager.default.copyItem(at: videoURL, to: copiedURLFile)
                        DispatchQueue.main.async {
                            // the videourl is deleted. Only copiedURLFile exists
                            // upload_to_firebase(video url)
                            let player = AVPlayer(url: copiedURLFile)
                            let playerVC = AVPlayerViewController()
                            playerVC.player = player
                            self.present(playerVC, animated: true, completion: nil)

                            // after the video is presented or the file uploaded, delete copiedURLFile
                        }
                    }
                    // the videourl is deleted. Only copiedURLFile exists
                }

            } else {
                debugPrint("invalid type identifier")
            }
        }
    }
}

