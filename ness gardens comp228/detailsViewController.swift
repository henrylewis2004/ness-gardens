//
//  detailsViewController.swift
//  ness gardens comp228
//
//  Created by Lewis, Henry on 10/12/2023.
//

import UIKit
import MapKit

class detailsViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var plantMap: MKMapView!
    @IBOutlet weak var slideshowImage: UIImageView!

    var plantDetails = Plant()
    var images = [UIImage]()
    var imageInfoArray = [ImageInfo]()

    @IBOutlet weak var last_modifiedLabel: UILabel!
    @IBOutlet weak var redlistLabel: UILabel!
    @IBOutlet weak var memoriamLabel: UILabel!
    @IBOutlet weak var bedLabel: UILabel!
    @IBOutlet weak var cidLabel: UILabel!
    @IBOutlet weak var cnamLabel: UILabel!
    @IBOutlet weak var altLabel: UILabel!
    @IBOutlet weak var locLabel: UILabel!
    @IBOutlet weak var sguLabel: UILabel!
    @IBOutlet weak var isoLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var donorLabel: UILabel!
    @IBOutlet weak var cultivarLabel: UILabel!
    @IBOutlet weak var vernacularLabel: UILabel!
    @IBOutlet weak var infraspecificLabel: UILabel!
    @IBOutlet weak var speciesLabel: UILabel!
    @IBOutlet weak var genusLabel: UILabel!
    @IBOutlet weak var familyLabel: UILabel!
    @IBOutlet weak var accstaLabel: UILabel!
    @IBOutlet weak var acidLabel: UILabel!
    
    
    
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        
        Task{
            await downloadImages()
            let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] timer in slideshowImage.image = images.randomElement()}
            timer.fire()
            updateText()
            
        }
        if (plantDetails.latitude != nil && plantDetails.longitude != nil && plantDetails.latitude != "" && plantDetails.longitude != ""){
            plantMap.alpha = 1
            let location = CLLocationCoordinate2D(latitude: Double(plantDetails.latitude!)!, longitude: Double(plantDetails.longitude!)!)
            let latDelta: CLLocationDegrees = 0.0025
            let lonDelta: CLLocationDegrees = 0.0025
            
            let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
            
            let region = MKCoordinateRegion(center: location, span: span)
            
            self.plantMap.setRegion(region, animated: true)
            plantMap.setCenter(location, animated: true)
            
            
        }
        else{
            plantMap.alpha = 0
        }
        
    }
    
    func downloadImages()async{
        imageInfoArray = []
        images = []
        let jsonDecoder = JSONDecoder()
        let recnum = plantDetails.recnum!
        let ImageInfoURL = URL(string: "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/ness/data.php?class=images&recnum=\(recnum)")!
        
        do{
            let (data,_) = try await URLSession.shared.data(from: ImageInfoURL)
            do{
                let result = try jsonDecoder.decode(ImageInfoResponse.self, from: data)
            
                imageInfoArray = result.images
                
            }
            catch DecodingError.keyNotFound(let key, _){print("image info key: \(key) not found ")}
            catch DecodingError.valueNotFound(let value, _){print("image info value: \(value) not found")}
           
            
        }
        catch{print("invalid image information data");return}
        if imageInfoArray.count > 0{
            for element in 1...imageInfoArray.count{
                let ImageURL = URL(string: "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/ness_images/\(recnum)-ID\(element).jpg")!
                do{
                    let (data,_) = try await URLSession.shared.data(from: ImageURL)
                    
                    images.append(UIImage(data:data)!)
                    
                }
                
                catch{print("invalid image data");return}
                
            }
        }
        
        
    }
    
    
    
    func updateText(){
        last_modifiedLabel.text = plantDetails.last_modified!.isEmpty ? "n/a" : plantDetails.last_modified
        redlistLabel.text = plantDetails.redlist!.isEmpty ? "n/a" : plantDetails.redlist
        memoriamLabel.text = plantDetails.memoriam!.isEmpty ? "n/a" : plantDetails.memoriam
        bedLabel.text = plantDetails.bed!.isEmpty ? "n/a" : plantDetails.bed
        cidLabel.text = plantDetails.cid!.isEmpty ? "n/a" : plantDetails.cid
        cnamLabel.text = plantDetails.cnam!.isEmpty ? "n/a" : plantDetails.cnam
        altLabel.text = plantDetails.alt!.isEmpty ? "n/a" : plantDetails.alt
        locLabel.text = plantDetails.loc!.isEmpty ? "n/a" : plantDetails.loc
        sguLabel.text = plantDetails.sgu!.isEmpty ? "n/a" : plantDetails.sgu
        isoLabel.text = plantDetails.iso!.isEmpty ? "n/a" : plantDetails.iso
        countryLabel.text = plantDetails.country!.isEmpty ? "n/a" : plantDetails.country
        donorLabel.text = plantDetails.donor!.isEmpty ? "n/a" : plantDetails.donor
        cultivarLabel.text = plantDetails.cultivar_name!.isEmpty ? "n/a" : plantDetails.cultivar_name
        vernacularLabel.text = plantDetails.vernacular_name!.isEmpty ? "n/a" : plantDetails.vernacular_name
        infraspecificLabel.text = plantDetails.infraspecific_epithet!.isEmpty ? "n/a" : plantDetails.infraspecific_epithet
        speciesLabel.text = plantDetails.species!.isEmpty ? "n/a" : plantDetails.species
        genusLabel.text = plantDetails.genus!.isEmpty ? "n/a" : plantDetails.genus
        familyLabel.text = plantDetails.family!.isEmpty ? "n/a" : plantDetails.family
        accstaLabel.text = plantDetails.accsta!.isEmpty ? "n/a" : plantDetails.accsta
        acidLabel.text = plantDetails.acid!.isEmpty ? "n/a" : plantDetails.acid
    }
}
