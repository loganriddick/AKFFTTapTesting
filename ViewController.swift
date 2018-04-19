//
//  ViewController.swift
//  FFTthing
//
//  Created by Chris on 4/16/18.
//  Copyright © 2018 Chris. All rights reserved.
//

import UIKit
import AudioKit
import Accelerate

class ViewController: UIViewController {

    var fftTap1: AKFFTTap!
    var fftTap2: AKFFTTap!
    var timer1: Timer!
    var timer2: Timer!
    var fft_buffer1=[Double](zeros: 512)
    var fft_buffer2=[Double](zeros: 512)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        first_fft()
    }
    func first_fft(){
        // Do any additional setup after loading the view, typically from a nib.
    
        let file = try! AKAudioFile(readFileName: "WhiteNoise.wav")
        
        let player = try! AKAudioPlayer(file: file)
        
        fftTap1=AKFFTTap(player)
        
        AudioKit.output = player
        try! AudioKit.start()
        player.play()
        
       
       /* let channels = UnsafeBufferPointer(start: file.pcmBuffer.floatChannelData, count: Int(file.pcmBuffer.format.channelCount))
 
        let buffdaddy: [Float]=Array(UnsafeBufferPointer(start: channels[0], count: Int(file.pcmBuffer.frameLength) )) */
        var count=1;
        print("back to here")
        var numtimes=0;
        timer1 = Timer(timeInterval: 1.0/30, repeats:true) { _ in
            if (count>90)
            {
                self.timer1.invalidate()
                var i=0;
                print(numtimes)
                while (i<self.fft_buffer1.count)
                {
                    self.fft_buffer1[i]=20*log(self.fft_buffer1[i]/numtimes);
                    i=i+1;
                }
               // print("after avg:")
                
                self.next_fft()
            }
            else
            { let data=self.fftTap1.fftData;
                let max=data.max()
                //print(count);
                if (max != 0)
                {
                    self.fft_buffer1=zip(self.fft_buffer1,data).map(+);
                    numtimes=numtimes+1;
                }
                count=count+1; }
        }
        RunLoop.current.add(timer1, forMode: .defaultRunLoopMode)
    
    }
    
    func next_fft()
    {
        do {
        print("made it to next fft")
        let file2 = try AKAudioFile(readFileName: "TestNoise.m4a")
        
        let player2 = try AKAudioPlayer(file: file2)
        
        fftTap2=AKFFTTap(player2)
        
        AudioKit.output = player2
        try! AudioKit.start()
        player2.play()
        
        var count=1;
        var numtimes=0;
        timer2 = Timer(timeInterval: 1.0/30, repeats:true) { _ in
            if (count>90)
            {
                self.timer2.invalidate()
                var i=0;
                print(numtimes)
                while (i<self.fft_buffer2.count)
                {
                    self.fft_buffer2[i]=20*log(self.fft_buffer2[i]/numtimes);
                    i=i+1;
                }
               // print("after avg:")
                self.calc_diff_gain()
                
            }
            else
            { let data=self.fftTap2.fftData;
                let max=data.max()
                //print(count);
                if (max != 0)
                {
                    self.fft_buffer2=zip(self.fft_buffer2,data).map(+);
                    numtimes=numtimes+1;
                }
                count=count+1; }
        }
            RunLoop.current.add(timer2, forMode: .defaultRunLoopMode)
        }
        catch {
            print("Major Error")
        }
        
    }
        
    
    func calc_diff_gain()
    {
        print("made it to diff gain")
        var i=0;
        var diff_gain_db=[Double](zeros: 512);
        print("fft buffer 1:")
        print(self.fft_buffer1)
        print("fft buffer 2:")
        print(self.fft_buffer2)
        var index=60;
        var sum=0.0;
        var div=0;
        while (index<100)
        {
            sum=sum+fft_buffer2[index];
            div=div+1;
            index=index+1;
        }
        print("avg sum")
        sum=sum/div;
        print(sum)
        while (i<diff_gain_db.count)
        {
            diff_gain_db[i]=sum-self.fft_buffer2[i];
            i=i+1;
        }
        print("diff gain: ")
        print(diff_gain_db)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

