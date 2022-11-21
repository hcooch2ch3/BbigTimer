//
//  ViewController.swift
//  BigTimer
//
//  Created by 임성민 on 2021/07/12.
//

import UIKit
import AVFoundation
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport

class TimerViewController: UIViewController {
    @IBOutlet weak var hour1Label: UILabel!
    @IBOutlet weak var hour2Label: UILabel!
    @IBOutlet weak var minute1Label: UILabel!
    @IBOutlet weak var minute2Label: UILabel!
    @IBOutlet weak var second1Label: UILabel!
    @IBOutlet weak var second2Label: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var currentHour1Label: UILabel!
    @IBOutlet weak var currentHour2Label: UILabel!
    @IBOutlet weak var currentTimeColon1Label: UILabel!
    @IBOutlet weak var currentMinute1Label: UILabel!
    @IBOutlet weak var currentMinute2Label: UILabel!
    @IBOutlet weak var currentTimeColon2Label: UILabel!
    @IBOutlet weak var currentSecond1Label: UILabel!
    @IBOutlet weak var currentSecond2Label: UILabel!
    
    var bannerView: GADBannerView!
    private let timer = HMSTimer()
    private let clock = Clock.shared
    private var alarmSoundPlayer: AVAudioPlayer?
    var isAwakeMode: Bool = {
        UserDefaults.standard.register(defaults: ["isAwakeMode": false])
        let isAwakeMode = UserDefaults.standard.bool(forKey: "isAwakeMode")
        UIApplication.shared.isIdleTimerDisabled = isAwakeMode
        return isAwakeMode
    }()
    {
        didSet {
            UserDefaults.standard.setValue(isAwakeMode, forKey: "isAwakeMode")
            UIApplication.shared.isIdleTimerDisabled = isAwakeMode
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeAlarmSound()
        setupNotifications()
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        addBannerViewToView(bannerView)
        bannerView.adUnitID = Constants.AdMob.adUnitID
        bannerView.rootViewController = self
        bannerView.delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (bool, error) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.requestIDFA()
            }
        }
        if !UserDefaults.standard.bool(forKey: "ads_removed") {
            NotificationCenter.default.addObserver(self, selector: #selector(handlePurchaseNotification(_:)), name: .iapServicePurchaseNotification, object: nil)
        } else {
            self.bannerView.isHidden = true
        }
    }
    
    @objc
    func handlePurchaseNotification(_ notification: Notification) {
        self.bannerView.isHidden = true
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(addTime), name: NSNotification.Name.addTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeTime), name: NSNotification.Name.changeTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeState), name: NSNotification.Name.changeState, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateClock), name: NSNotification.Name.updateClock, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notifyTimeOver), name: NSNotification.Name.timeOver, object: nil)
    }

    private func requestIDFA() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                self.bannerView.load(GADRequest())
            })
        } else {
            self.bannerView.load(GADRequest())
        }
    }
    
    private func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
          [NSLayoutConstraint(item: bannerView,
                              attribute: .bottom,
                              relatedBy: .equal,
                              toItem: view.safeAreaLayoutGuide,
                              attribute: .bottom,
                              multiplier: 1,
                              constant: 0),
           NSLayoutConstraint(item: bannerView,
                              attribute: .centerX,
                              relatedBy: .equal,
                              toItem: view,
                              attribute: .centerX,
                              multiplier: 1,
                              constant: 0)
          ])
       }
    
    @objc private func updateClock(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: String],
              let currentDate = userInfo["date"],
              let currentHour = userInfo["hour"],
              let currentMinute = userInfo["minute"],
              let currentSecond = userInfo["second"] else {
            self.currentDateLabel.text = ""
            self.currentHour1Label.text = ""
            self.currentHour2Label.text = ""
            self.currentMinute1Label.text = ""
            self.currentMinute2Label.text = ""
            self.currentSecond1Label.text = ""
            self.currentSecond2Label.text = ""
            self.currentTimeColon1Label.text = ""
            self.currentTimeColon2Label.text = ""
            return
        }
        self.currentTimeColon1Label.text = ":"
        self.currentTimeColon2Label.text = ":"
        
        self.currentDateLabel.text = currentDate
        
        let index0 = currentHour.index(currentHour.startIndex, offsetBy: 0)
        let index1 = currentHour.index(currentHour.startIndex, offsetBy: 1)
        self.currentHour1Label.text = String(currentHour[index0])
        self.currentHour2Label.text = String(currentHour[index1])
        
        let index2 = currentMinute.index(currentMinute.startIndex, offsetBy: 0)
        let index3 = currentMinute.index(currentMinute.startIndex, offsetBy: 1)
        self.currentMinute1Label.text = String(currentMinute[index2])
        self.currentMinute2Label.text = String(currentMinute[index3])
        
        let index4 = currentSecond.index(currentSecond.startIndex, offsetBy: 0)
        let index5 = currentSecond.index(currentSecond.startIndex, offsetBy: 1)
        self.currentSecond1Label.text = String(currentSecond[index4])
        self.currentSecond2Label.text = String(currentSecond[index5])
    }

    @objc private func addTime(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: UInt] else {
            return
        }
        if let hour = userInfo["hour"],
           let minute = userInfo["minute"],
           let second = userInfo["second"] {
            timer.addTime(hour: hour, minute: minute, second: second)
        }
        playButton.isEnabled = true
    }
    
    @objc private func changeTime(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: String] else {
            return
        }
        if let hour = userInfo["hour"] {
            let index0 = hour.index(hour.startIndex, offsetBy: 0)
            let index1 = hour.index(hour.startIndex, offsetBy: 1)
            self.hour1Label.text = String(hour[index0])
            self.hour2Label.text = String(hour[index1])
        }
        if let minute = userInfo["minute"] {
            let index0 = minute.index(minute.startIndex, offsetBy: 0)
            let index1 = minute.index(minute.startIndex, offsetBy: 1)
            self.minute1Label.text = String(minute[index0])
            self.minute2Label.text = String(minute[index1])
        }
        if let second = userInfo["second"] {
            let index0 = second.index(second.startIndex, offsetBy: 0)
            let index1 = second.index(second.startIndex, offsetBy: 1)
            self.second1Label.text = String(second[index0])
            self.second2Label.text = String(second[index1])
        }
    }
    
    @objc private func changeState(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: HMSTimer.TimerState],
              let timerState = userInfo["state"] else {
            return
        }
        
        /// 시간 추가 전 - 더하기 버튼 활성화, 재생 버튼 비활성화, 중지 버튼 비활성화
        /// 시간 추가 후 - 더하기 버튼 비활성화, 재생 버튼 활성화, 중지 버튼 활성화
        /// 재생 - 더하기 버튼 비활성화, 재생 버튼 정지 버튼으로 변경, 중지 버튼 활성화
        /// 정지 - 더하기 버튼 비활성화, 정지 버튼 재생 버튼으로 변경, 중지 버튼 활성화
        switch timerState {
        case .BeforeAddingTime:
            addButton.isEnabled = true
            playButton.isEnabled = false
            stopButton.isEnabled = false
            playButton.setImage(UIImage(systemName: "play"), for: .normal)
        case .AfterAddingTime:
            addButton.isEnabled = false
            playButton.isEnabled = true
            stopButton.isEnabled = true
        case .play:
            playButton.setImage(UIImage(systemName: "pause"), for: .normal)
        case .pause:
            playButton.setImage(UIImage(systemName: "play"), for: .normal)
        }
    }
    
    @objc private func notifyTimeOver() {
        self.alarmSoundPlayer?.play()
        showAlert(message: "Time Over") {
            self.alarmSoundPlayer?.stop()
        }
    }
    
    @IBAction func touchUpAddButton(_ sender: Any) {
        let timePicker = UINavigationController(rootViewController: TimePickerViewController())
        timePicker.preferredContentSize = CGSize(width: 300, height: 300)
        timePicker.modalPresentationStyle = .popover
        timePicker.popoverPresentationController?.sourceView = addButton
        present(timePicker, animated: true, completion: nil)
    }
    
    @IBAction func touchUpPlayButton(_ sender: Any) {
        switch timer.state {
        case .play:
            timer.pause()
        case .pause, .AfterAddingTime:
            timer.play()
        default:
            break
        }
    }
    
    @IBAction func touchUpStopButton(_ sender: Any) {
        timer.stop()
    }
    
    @IBAction func touchUpSettingButton(_ sender: Any) {
        let settingsTableViewController = SettingsTableViewController(style: .grouped)
        settingsTableViewController.timerViewController = self
        let settings = UINavigationController(rootViewController: settingsTableViewController)
        settings.preferredContentSize = CGSize(width: 300, height: 300)
        settings.modalPresentationStyle = .popover
        settings.popoverPresentationController?.sourceView = settingButton
        present(settings, animated: true, completion: nil)
    }
    
    func showAlert(message: String, okActionHandler: (() -> Void)?) {
        let alert: UIAlertController = UIAlertController(title: "BbigTimer", message: message, preferredStyle: UIAlertController.Style.alert)
        
        let okAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (action: UIAlertAction) -> Void in
            okActionHandler?()
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func initializeAlarmSound() {
        guard let soundAsset: NSDataAsset = NSDataAsset(name: "alarm_sound") else {
            showAlert(message: "음원 파일 에셋을 가져올 수 없습니다", okActionHandler: nil)
            print("음원 파일 에셋을 가져올 수 없습니다")
            return
        }
        do {
            try self.alarmSoundPlayer = AVAudioPlayer(data: soundAsset.data)
        } catch let error as NSError {
            showAlert(message: "플레이어 초기화 실패", okActionHandler: nil)
            print("플레이어 초기화 실패")
            print("코드 : \(error.code), 메세지 : \(error.localizedDescription)")
        }
    }
}

extension TimerViewController: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 1
        })
    }
}

