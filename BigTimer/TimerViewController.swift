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
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var minuteLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var clockLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    
    var bannerView: GADBannerView!
    private let timer = HMSTimer()
    private let clock = Clock()
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (bool, error) in
        }
        initializeAlarmSound()
        setupNotifications()
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        addBannerViewToView(bannerView)
        bannerView.adUnitID = Constants.AdMob.adUnitID
        bannerView.rootViewController = self
        bannerView.delegate = self
        DispatchQueue.global().async {
            self.requestIDFA()
        }
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
              let clock = userInfo["clock"] else {
            return
        }
        self.clockLabel.text = clock
    }

    @IBAction func touchUpPlusButton(_ sender: Any) {
        let timePicker = TimePickerViewController()
        let picker = UINavigationController(rootViewController: timePicker)
        present(picker, animated: true, completion: nil)
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
        guard let userInfo = notification.userInfo as? [String: UInt] else {
            return
        }
        if let hour = userInfo["hour"] {
            self.hourLabel.text = hour.timeString
        }
        if let minute = userInfo["minute"] {
            self.minuteLabel.text = minute.timeString
        }
        if let second = userInfo["second"] {
            self.secondLabel.text = second.timeString
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

