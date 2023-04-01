//
//  ContentView.swift
//  TestUrl
//
//  Created by 甄子智 on 2023/4/1.
//

import SwiftUI
let arr:Array<String> = [
    "https://haokan.baidu.com/?sfrom=baidu-top",
    "https://blog.csdn.net/tinghe17/article/details/126647128",
    "https://tieba.baidu.com/index.html",
    "https://www.baidu.com",
    "https://baike.baidu.com/item/SWIFT/14080957?fr=aladdin",
    "https://www.xyhtml5.com/21386.html",
    "https://www.jianshu.com/p/c0b7cd2db4df",
    "https://www.oschina.net/p/swift-lang?hmsr=aladdin1e1",
    "https://cn.bing.com/dict/swift",
    "https://www.apple.com.cn/swift/"
]

var fastTime:Double = 10000
var fastUrl = "0"
var map = [String:[Int64]]()

class Model: ObservableObject {
    @Published var textValue: String = ""
}
var models = Model()

struct ContentView: View {
    @ObservedObject var model = models
   
    var body: some View {
        VStack (alignment: .center, spacing: 20){
            Button(action: {
                TestUrl()
            }, label: {
                Image(systemName: "clock")
                Text("开始检测")
            })
            .foregroundColor(Color.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(5)
            Text(model.textValue)
                .font(.footnote)
                .frame(width: 200, height: 200)
                .transition(.opacity)
        }
        
    }
}
func TestUrl(){
    let group = DispatchGroup()
    for urlStr in arr{
        map[urlStr] = []
        print(urlStr)
        for _ in 0...5{
//            DispatchQueue.global().async {
//                group.enter()
//
//            }
            NetworkRequest(urlStr: urlStr,group: group)
        }
    }
    group.notify(queue: .main){
        print(map)
        for (key, value) in map {
            let sum = value.reduce(0, +)
            let avge = Double(sum)/Double(value.count)
            if avge > 0 && avge < fastTime{
                fastTime = avge
                fastUrl = key
            }
            //print("fastUrl = \(fastUrl),fastTime = \(fastTime)")
        }
        models.textValue = "平均响应最快url：\(fastUrl),   平均响应时间(毫秒)：\(fastTime)"
    }
}
func NetworkRequest(urlStr:String,group:DispatchGroup){

    if let url = URL(string: urlStr) {
        
        let startTime = Int64(Date().timeIntervalSince1970 * 1000)
        group.enter()
        let completionHandler: (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void  = { data,_,_ in
            if let _ = data{
                let endTime = Int64(Date().timeIntervalSince1970 * 1000)
                let time = endTime - startTime
                if time > 10{
                    var arr = map[urlStr]!
                    arr.append(time)
                    map[urlStr] = arr
                }
                print("\(urlStr)代码执行时长：\(time) 毫秒")
            }
            group.leave()
        }
        let sessionConfig = URLSessionConfiguration.default
                sessionConfig.timeoutIntervalForRequest = 1.0
        let task = URLSession(configuration: sessionConfig).dataTask(with: url, completionHandler: completionHandler)
        task.resume()
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
