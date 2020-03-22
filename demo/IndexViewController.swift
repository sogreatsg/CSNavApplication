//
//  IndexViewController.swift
//  demo
//
//  Created by KITTISAK SRIDET on 29/11/2562 BE.
//  Copyright © 2562 KITTISAK SRIDET. All rights reserved.
//

import UIKit


class IndexViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var pageControl : UIPageControl!
    @IBOutlet weak var scrollView : UIScrollView!

    var images: [String] = ["intro1","intro2","intro3"]
    var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    
    @IBOutlet weak var intro: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("IndexViewController")
        // Do any additional setup after loading the view.
        pageControl.numberOfPages = images.count
        for index in 0..<images.count {
            frame.origin.x = scrollView.frame.size.width * CGFloat(index)
            frame.size = scrollView.frame.size
            let imgView = UIImageView(frame: frame)
            imgView.image = UIImage(named: images[index])
            self.scrollView.addSubview(imgView)
        }
        scrollView.contentSize = CGSize(width:(scrollView.frame.size.width * CGFloat(images.count)),height:scrollView.frame.size.height)
        scrollView.delegate = self
      
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = scrollView.contentOffset.x / scrollView.frame.size.width
        pageControl.currentPage = Int(pageNumber)
    }
    
    @IBAction func indexButton(_ sender: Any) {
        print("ButtonClicked")
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
