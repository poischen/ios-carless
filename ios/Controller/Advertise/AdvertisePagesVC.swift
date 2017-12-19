import UIKit

class AdvertisePagesVC: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    //Manage pageview for advertising a car --------------------------------------------------------------------
    lazy var AdvertisementViewControllersArray: [UIViewController] = {
        return [self.ViewControllerInstance(name: "advertisePageController1"),
                self.ViewControllerInstance(name: "advertisePageController2"),
                self.ViewControllerInstance(name: "advertisePageController3"),
                self.ViewControllerInstance(name: "advertisePageController4"),
                self.ViewControllerInstance(name: "advertisePageController5"),
                self.ViewControllerInstance(name: "advertisePageController6"),
                self.ViewControllerInstance(name: "advertisePageController7")]
    }()
    
    private func ViewControllerInstance(name: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: name)
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

