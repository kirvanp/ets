//
//  TodayViewController.swift
//  Gliding Centre Flights
//
//  Created by Paul Kirvan on 2015-01-03.
//
//

import UIKit
import NotificationCenter

final class TodayViewController: UITableViewController, NCWidgetProviding
{
    let keyValueStore = NSUbiquitousKeyValueStore.default
    var activeGlidingCentres = [GlidingCentreData]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 44
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateInfo), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: nil)

    }
    
    func widgetPerformUpdate(completionHandler: @escaping (NCUpdateResult) -> Void)
    {
        updateInfo()
        completionHandler(NCUpdateResult.newData)
    }
    
    @objc func updateInfo()
    {
        activeGlidingCentres.removeAll(keepingCapacity: true)
        let keyValueStoreData = keyValueStore.dictionaryRepresentation

        for gcName in keyValueStoreData.keys
        {
            let gcDataDictionary = keyValueStoreData[gcName] as! [String: AnyObject]
            let processedData = GlidingCentreData(name: gcName, gcData: gcDataDictionary)
            print("\(processedData)")
            
            if processedData.activeInLast100Days == true
            {
                activeGlidingCentres.append(processedData)
                print("The GC name \(processedData.gcName)")
            }
        }
        
        activeGlidingCentres.sort(by: >)
        preferredContentSize = CGSize(width: 0, height: tableView.contentSize.height)

        let controller = NCWidgetController()
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {return}

        controller.setHasContent(true, forWidgetWithBundleIdentifier: bundleIdentifier)
        tableView.reloadData()
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize)
    {
        switch activeDisplayMode
        {
        case NCWidgetDisplayMode.compact:
            preferredContentSize = maxSize

        case NCWidgetDisplayMode.expanded:
            preferredContentSize = CGSize(width: 0, height: tableView.contentSize.height)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StandardCell", for: indexPath)
        let gcInfo = activeGlidingCentres[(indexPath as NSIndexPath).row]
        
        var cellTitle = gcInfo.gcName
        
        if gcInfo.hasFlownToday
        {
            cellTitle += " (Last Launch \(gcInfo.mostRecentFlight.hoursAndMinutes))"
        }
        
        cell.textLabel?.text = cellTitle
        
        var cellDetailLabel = "\(gcInfo.flightsToday) Flight"
        
        if gcInfo.flightsToday != 1
        {
            cellDetailLabel += "s"
        }
        
        let fiveDaysAgo = Date(timeInterval: (-4*24*60*60), since: Date().midnight)
        cellDetailLabel += " (\(gcInfo.flightsInLastFiveDays) since \(fiveDaysAgo.militaryFormatShort))"
        cell.detailTextLabel?.text = cellDetailLabel
        
        let GCImage = UIImage(named: gcInfo.gcName)
        cell.imageView?.image = GCImage
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return activeGlidingCentres.count
    }
}
