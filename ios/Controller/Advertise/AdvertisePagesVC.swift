import UIKit

class AdvertisePagesVC: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UINavigationBarDelegate {
    
    var carImage: UIImage!
    let storageAPI = StorageAPI.shared
    let advertise = Advertise.shared
    let advertiseHelper = AdvertiseHelper()
    
    let IDENTIFIER_OFFERING_NAV = "OfferingNavigation"
    
    @IBAction func cancelAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    //writes offer to db if all inputs are availible
    func writeOfferToDB(){
        let offeringDict = advertiseHelper.getOfferDict()
        print(offeringDict)
        if offeringDict.count > 0 {
            print(offeringDict)
            let offer = Offering(id: "empty", dict: offeringDict)
            
        //store offering
            storageAPI.saveOffering(offer: offer!, completion: {offerWithID in
                if let offerID = offerWithID.id {
                    //store avilibility by Offer ID
                    self.storageAPI.saveAvailibility(blockedDates: self.advertiseHelper.blockedDates, offerID: offerID)
                    //store features by Offer ID
                    self.storageAPI.saveFeatures(features: self.advertiseHelper.convertFeatures(), offerID: offerID)
                }
                
                //switch to offer view
                let storyboard = UIStoryboard(name: "Offering", bundle: nil)
                let navController = storyboard.instantiateViewController(withIdentifier: self.IDENTIFIER_OFFERING_NAV) as! UINavigationController
                let offeringController = navController.topViewController as! OfferingViewController
                offeringController.displayingOffering = offerWithID
                offeringController.cameFromAdvertise = true
                offeringController.advertisePagesController = self
                self.present(navController, animated: true, completion: nil)
                
            })
            
        } else {
            let alertMissingInputs = UIAlertController(title: "Something is missing", message: "Please check all inputs and try again.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style:.default, handler: nil)
            alertMissingInputs.addAction(ok)
            self.present(alertMissingInputs, animated: true, completion: nil)
        }
    }
    
    //Manage pageview for advertising a car --------------------------------------------------------------------
    lazy var AdvertisementViewControllersArray: [UIViewController] = {
        return [self.ViewControllerInstance(name: "advertisePage1"),
                self.ViewControllerInstance(name: "advertisePage2"),
                self.ViewControllerInstance(name: "advertisePage3"),
                self.ViewControllerInstance(name: "advertisePage4"),
                self.ViewControllerInstance(name: "advertisePage5"),
                self.ViewControllerInstance(name: "advertisePage6"),
                self.ViewControllerInstance(name: "advertisePage7")]
    }()
    
    private func ViewControllerInstance(name: String) -> UIViewController {
        return UIStoryboard(name: "Advertise", bundle: nil).instantiateViewController(withIdentifier: name)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        
        if let firstViewController = AdvertisementViewControllersArray.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
        let pageControl = UIPageControl.appearance(whenContainedInInstancesOf: [AdvertisePagesVC.self])
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = Theme.palette.orange
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for view in self.view.subviews {
            if view is UIScrollView {
                view.frame = UIScreen.main.bounds
            } else if view is UIPageControl {
                view.backgroundColor = UIColor.clear
            }
        }
        
    }
    
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = AdvertisementViewControllersArray.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return AdvertisementViewControllersArray.last
        }
        
        guard AdvertisementViewControllersArray.count > previousIndex else {
            return nil
        }
        
        return AdvertisementViewControllersArray[previousIndex]
    }

    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = AdvertisementViewControllersArray.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < AdvertisementViewControllersArray.count else {
            return AdvertisementViewControllersArray.first
        }
        
        guard AdvertisementViewControllersArray.count > nextIndex else {
            return nil
        }
        
        return AdvertisementViewControllersArray[nextIndex]
    }
    
    public func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return AdvertisementViewControllersArray.count
    }
    
    
    public func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = AdvertisementViewControllersArray.index(of: firstViewController) else {
                return 0
        }
        
        return firstViewControllerIndex
    }
    
    func back() -> Void {
        navigationController?.popViewController(animated: true)
    }
    
}

