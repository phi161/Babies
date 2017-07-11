//
//  AdultTypeTableViewController.swift
//  Babies
//
//  Created by phi161 on 17/05/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import UIKit
import CoreData

protocol AdultTypePickerDelegate: class {
    func adultTypePicker(_ adultTypePicker: AdultTypeTableViewController, didSelectType type: AdultType)
    func adultTypePickerDidCancel(_ adultTypePicker: AdultTypeTableViewController)
}

class AdultTypeTableViewController: UITableViewController {

    var adultType: AdultType?
    weak var delegate: AdultTypePickerDelegate?
    var managedObjectContext: NSManagedObjectContext?

    var adultTypes: [AdultType]? {
        do {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "AdultType")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "identifier", ascending: true)]
            var result: [AdultType]?
            result = try self.managedObjectContext?.fetch(fetchRequest) as? [AdultType]
            return result
        } catch {
            let fetchError = error as NSError
            print(fetchError)
            return nil
        }
    }

    // MARK: - Setup

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped(_:)))

        if adultTypes?.count == 0 {
            importFromJSON()
            tableView.reloadData()
        }

        title = NSLocalizedString("ADULT_TYPE_TITLE", comment: "The title of the view for selecting adult type")
    }

    func importFromJSON() {
        let jsonFileURL = Bundle.main.url(forResource: "adult_types", withExtension: "json")

        if let jsonData = try? Data(contentsOf: jsonFileURL!) {
            do {
                let jsonArray: Array! = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [[String:AnyObject]]
                for item in jsonArray {

                    guard let title = item["key"] as? String, let identifier = item["identifier"] as? Int else {
                        return
                    }

                    let adultType = AdultType(title: title, identifier: identifier, userDefined: false, context: managedObjectContext!)
                    managedObjectContext?.insert(adultType)

                }

                do {
                    try managedObjectContext!.save()
                    print("Saved main context!")
                } catch {
                    print("Error for main: \(error)")
                }

            } catch {
                print(error)
            }
        }
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = adultTypes?.count {
            return count
        } else {
            return 0
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "AdultTypeCellIdentifier", for: indexPath)

        if let currentAdultType = adultTypes?[indexPath.row], let key = currentAdultType.title {
            cell.textLabel?.text = NSLocalizedString(key, comment: "")
            cell.accessoryType = .none
            if let selectedAdultRow = self.adultType?.identifier?.intValue,
                indexPath.row == selectedAdultRow {
                cell.accessoryType = .checkmark
            }
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let selectedAdultRow = self.adultType?.identifier?.intValue,
            let selectedCell = tableView.cellForRow(at: IndexPath(row: selectedAdultRow, section: 0)) {
            selectedCell.accessoryType = .none
        }

        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }

        delegate?.adultTypePicker(self, didSelectType: (adultTypes?[indexPath.row])!)
    }

    // MARK: Actions

    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        delegate?.adultTypePickerDidCancel(self)
    }

}
