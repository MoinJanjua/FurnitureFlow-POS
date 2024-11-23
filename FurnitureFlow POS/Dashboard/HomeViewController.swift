//
//  HomeViewController.swift
//  NameSpectrum Hub
//
//  Created by Maaz on 03/10/2024.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var CollectionView: UICollectionView!
  
    var type = [String]()
    var Imgs: [UIImage] = [UIImage(named: "adduser")!,
        UIImage(named: "customer")!,
        UIImage(named: "furniture")!,
        UIImage(named: "createorder")!,
        UIImage(named: "generate")!,
                           UIImage(named: "setting")!]

    override func viewDidLoad() {
        super.viewDidLoad()
   
        type = ["Add Customers","Customers","Furitures","Create Order","Generated Sales","Settings"]
        
        CollectionView.dataSource = self
        CollectionView.delegate = self
        CollectionView.collectionViewLayout = UICollectionViewFlowLayout()

    }
   
}
extension HomeViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return type.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! HCollectionViewCell
    
        cell.Label.text = type [indexPath.item]
        cell.images.image? =  Imgs [indexPath.item]
        
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width
        let spacing: CGFloat = 10
        let availableWidth = collectionViewWidth - (spacing * 3)
        let width = availableWidth / 2
        return CGSize(width: width + 3, height: width + 14)
      // return CGSize(width: wallpaperCollectionView.frame.size.width , height: wallpaperCollectionView.frame.size.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10 // Adjust as needed
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 5, bottom: 20, right: 5) // Adjust as needed
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row == 0
            {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                          let newViewController = storyBoard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
                          newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
                          newViewController.modalTransitionStyle = .crossDissolve
                          self.present(newViewController, animated: true, completion: nil)
        }
        
        if indexPath.row == 1
        {

            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "UserViewController") as! UserViewController
          
            newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            newViewController.modalTransitionStyle = .crossDissolve
            self.present(newViewController, animated: true, completion: nil)
          
        }
        
        if indexPath.row == 2
        {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                          let newViewController = storyBoard.instantiateViewController(withIdentifier: "ProductViewController") as! ProductViewController
                          newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
                          newViewController.modalTransitionStyle = .crossDissolve
                          self.present(newViewController, animated: true, completion: nil)
            
               
        }
        
        if indexPath.row == 3
        {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "OrderViewController") as! OrderViewController
            
            newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            newViewController.modalTransitionStyle = .crossDissolve
           self.present(newViewController, animated: true, completion: nil)

        }
        if indexPath.row == 4
        {
       
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "RecordsViewController") as! RecordsViewController
            newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            newViewController.modalTransitionStyle = .crossDissolve
            self.present(newViewController, animated: true, completion: nil)
        }
        if indexPath.row == 5
        {
       
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
            newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            newViewController.modalTransitionStyle = .crossDissolve
            self.present(newViewController, animated: true, completion: nil)
        }
    }
}
