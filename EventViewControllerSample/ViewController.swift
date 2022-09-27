import UIKit
import EventKit
import EventKitUI

class ViewController: UITableViewController {
    var events: [EKEvent] = []
    var eventStore: EKEventStore = EKEventStore()

    override func viewDidLoad() {
        super.viewDidLoad()

        let status = EKEventStore.authorizationStatus(for: .event)
        if status == .authorized {
            loadEvent()
        } else {
            requestAccess()
        }
    }

    func requestAccess() {
        EKEventStore().requestAccess(to: .event) { granted, error in
            if granted {
                self.eventStore = EKEventStore()
                DispatchQueue.main.async {
                    self.loadEvent()
                }
                return
            }

            let alert = UIAlertController(title: "no access to calendar", message: nil, preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(alert, animated: true)
        }
    }

    func  loadEvent() {
        let predicate = self.eventStore.predicateForEvents(withStart: Date(), end: Date() + 3600 * 24, calendars: nil)
        events = self.eventStore.events(matching: predicate)
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else { fatalError() }
        let event = events[indexPath.row]
        cell.textLabel?.text = event.title
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = events[indexPath.row]
        let e = EKEventViewController()
        e.event = event
        navigationController?.pushViewController(e, animated: true)
    }
}
