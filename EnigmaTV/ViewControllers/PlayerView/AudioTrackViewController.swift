//
//  AudioTrackViewController.swift
//  EnigmaTV
//
//  Created by Damian Skarżyński on 09/01/2020.
//  Copyright © 2020 Blazej Zyglarski. All rights reserved.
//

import UIKit
import AVKit

class AudioTrackViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    
    
    @IBOutlet weak var audioTracksTable: UITableView!
    @IBOutlet weak var subtitlesTable: UITableView!
    @IBOutlet weak var audioDestinationView: UIView!
    //    @IBOutlet weak var audioDestinationTable: UITableView!
    
    weak var sv:StreamView? {
        didSet{
            //zostało ustawione
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        audioTracksTable.dataSource = self
        audioTracksTable.delegate = self
        audioTracksTable.register(UITableViewCell.self, forCellReuseIdentifier: "audioTracksCell")
        
        subtitlesTable.dataSource = self
        subtitlesTable.delegate = self
        subtitlesTable.register(UITableViewCell.self, forCellReuseIdentifier: "subtitlesCell")
        
        //        sv?.mp?.currentAudioTrackIndex = 0
        
        //        audioDestinationView = AVRoutePickerView()
        
        let AirPlayButton = AVRoutePickerView(frame: CGRect(x: 1600, y: 220, width: 66, height: 66))
        
//        AirPlayButton.docus
        view.addSubview(AirPlayButton)
        
        //        let AirPlayButton = AVRoutePickerView()
        //        audioDestinationView.addSubview(AirPlayButton)
        
        print("AudioTrackVC - ")
        print("AudioTrackVC - subtitleTracksNames : \(sv?.mp?.videoSubTitlesNames)")
        
        print("AudioTrackVC - audioTracksNames : \(sv?.mp?.audioTrackNames)")
        print("AudioTrackVC - audioTracksIndexes : \(sv?.mp?.audioTrackIndexes)")
        print("AudioTrackVC - currentAudioTrackIndex: \(sv?.mp?.currentAudioTrackIndex)")
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count:Int?
        
        if tableView == self.audioTracksTable {
            count = sv?.mp?.audioTrackNames.count
        }
        
        if tableView == self.subtitlesTable {
            count = sv?.mp?.videoSubTitlesNames.count
        }
        
        
        return count!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        
        if tableView == self.audioTracksTable {
            cell = tableView.dequeueReusableCell(withIdentifier: "audioTracksCell", for: indexPath)
            if let index = sv?.mp?.audioTrackIndexes[indexPath.row], index as! Int32 == sv?.mp?.currentAudioTrackIndex{
                
                let title = sv?.mp?.audioTrackNames[indexPath.row] as! String
                cell!.textLabel!.text = "✔️ \(title)"
                cell!.textLabel!.font = cell!.textLabel!.font.withSize(30)
            }else{
                let title = sv?.mp?.audioTrackNames[indexPath.row] as! String
                cell!.textLabel!.text = title
                cell!.textLabel!.font = cell!.textLabel!.font.withSize(30)
            }
            
        }
        
        if tableView == self.subtitlesTable {
            cell = tableView.dequeueReusableCell(withIdentifier: "subtitlesCell", for: indexPath)
            
            if let index = sv?.mp?.videoSubTitlesIndexes[indexPath.row], index as! Int32 == sv?.mp?.currentVideoSubTitleIndex{
                
                let title = sv?.mp?.videoSubTitlesNames[indexPath.row] as! String
                
                cell!.textLabel!.text = "✔️ \(title)"
                cell!.textLabel!.font = cell!.textLabel!.font.withSize(30)
            }else{
                let title = sv?.mp?.videoSubTitlesNames[indexPath.row] as! String
                
                cell!.textLabel!.text = title
                cell!.textLabel!.font = cell!.textLabel!.font.withSize(30)
            }
        }
        
        
        
        return cell!
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch tableView {
        case audioTracksTable:
            print("AudioTrackVC - audio row clicked = \(indexPath.row)")
            print("AudioTrackVC - audio row index = \(sv?.mp?.audioTrackIndexes[indexPath.row])")
            if let index = sv?.mp?.audioTrackIndexes[indexPath.row]{
                sv?.mp?.audioChannel = index as! Int32
                sv?.mp?.currentAudioTrackIndex  = index as! Int32
                //sv?.mp?.
            }
            
        case subtitlesTable:
            print("AudioTrackVC - subtitles row clicked = \(indexPath.row)")
            print("AudioTrackVC - audio row index = \(sv?.mp?.videoSubTitlesIndexes[indexPath.row])")
            if let index = sv?.mp?.videoSubTitlesIndexes[indexPath.row]{
                sv?.mp?.currentVideoSubTitleIndex = index as! Int32
                //sv?.mp?.
            }
            
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
