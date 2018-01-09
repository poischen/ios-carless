import UIKit

class AdvertisePagesVC: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UINavigationBarDelegate {
    
    var carImage: UIImage!
    let storageAPI = StorageAPI.shared
    let advertise = Advertise.shared
    let advertiseHelper = AdvertiseHelper()
    
    @IBAction func navBackButton(_ sender: Any) {
        back()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        /*//load necessary information into model
        storageAPI.getBrands(completion: advertise.receiveBrands)
        storageAPI.getFuels(completion: advertise.receiveFuels)
        storageAPI.getGears(completion: advertise.receiveGears)
        storageAPI.getVehicleTypes(completion: advertise.receiveVehicleTypes)
        storageAPI.getFeatures(completion: advertise.receiveFeatures)*/
    }
    
    //writes offer to db if all inputs are availible
    func writeOfferToDB(){
        if let offeringDict = advertiseHelper.getOfferDict() {
            print(offeringDict)
            let offer = Offering(id: "empty", dict: offeringDict)
            storageAPI.saveOffering(offer: offer!, completion: {offerWithID in
                let storyboard = UIStoryboard(name: "Offering", bundle: nil)
                if let viewController = storyboard.instantiateViewController(withIdentifier: "Offering") as? OfferingViewController{
                    viewController.displayingOffering = offerWithID
                    self.present(viewController, animated: true, completion: nil)
                }
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
        pageControl.currentPageIndicatorTintColor = UIColor.init(red: 1.00, green: 0.57, blue: 0.57, alpha: 1.0)
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

