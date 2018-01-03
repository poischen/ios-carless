import UIKit

class AdvertisePagesVC: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    var offeringDict: [String : AnyObject] {
        return [
            Constants.OFFERING_BRAND_ID_KEY: 0 as AnyObject,
            Constants.OFFERING_CONSUMPTION_KEY: 0 as AnyObject,
            Constants.OFFERING_DESCRIPTION_KEY: "empty" as AnyObject,
            Constants.OFFERING_FUEL_ID_KEY: 0 as AnyObject,
            Constants.OFFERING_GEAR_ID_KEY: 0 as AnyObject,
            Constants.OFFERING_HP_KEY: 0 as AnyObject,
            Constants.OFFERING_LATITUDE_KEY: 0.0 as AnyObject,
            Constants.OFFERING_LOCATION_KEY: "empty" as AnyObject,
            Constants.OFFERING_LONGITUDE_KEY: 0.0 as AnyObject,
            Constants.OFFERING_PICTURE_URL_KEY: "empty" as AnyObject,
            Constants.OFFERING_PRICE_KEY: 0 as AnyObject,
            Constants.OFFERING_SEATS_KEY: 0 as AnyObject,
            Constants.OFFERING_TYPE_KEY: 0 as AnyObject,
            Constants.OFFERING_USER_UID_KEY: 0 as AnyObject,
            Constants.OFFERING_VEHICLE_TYPE_ID_KEY: 0 as AnyObject,
            Constants.OFFERING_PICKUP_TIME_KEY: "empty" as AnyObject,
            Constants.OFFERING_RETURN_TIME_KEY: "empty" as AnyObject
        ]
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
    
    
}

