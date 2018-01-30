//
//  MemoriesCollectionViewController.swift
//  GloryDays
//
//  Created by Aldo Aram Martinez Mireles on 1/28/18.
//  Copyright © 2018 Aldo Aram Martinez Mireles. All rights reserved.
//

import UIKit

import AVFoundation
import Photos
import Speech

private let reuseIdentifier = "cell"

class MemoriesCollectionViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegateFlowLayout {
    
    var memories : [URL] = []
    var vc = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        vc.delegate = self
        
        loadMemories()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Se crea el boton derecho de la barra de navegacion de agregar desde codigo.
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addImagePressed))

        // Register cell classes
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.checkForGrantedPermissions()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Funcion para verificar que todos los permisos se hayan otorgado
    func checkForGrantedPermissions(){
        let photosAuth : Bool = PHPhotoLibrary.authorizationStatus() == .authorized
        let audioAuth : Bool = AVAudioSession.sharedInstance().recordPermission() == .granted
        let speechAuth = SFSpeechRecognizer.authorizationStatus() == .authorized
        
        let permissions = photosAuth && audioAuth && speechAuth
        
        if !permissions{
            if let vc = storyboard?.instantiateViewController(withIdentifier: "showTerms"){
                navigationController?.present(vc, animated: true)            }
        }
    }
    
    func loadMemories(){
        self.memories.removeAll()
        
        guard let files = try? FileManager.default.contentsOfDirectory(at: getDocumentDirectory(), includingPropertiesForKeys: nil, options: []) else {
            return
        }
        
        for file in files{
            let fileName = file.lastPathComponent
            
            if fileName.hasSuffix(".thumb"){
                let noExtension = fileName.replacingOccurrences(of: ".thumb", with: "")
                
                let memoryPath = getDocumentDirectory().appendingPathComponent(noExtension)
                self.memories.append(memoryPath)
            }
        }
        
        collectionView?.reloadSections(IndexSet(integer : 1))
    }
    
    func getDocumentDirectory() -> URL {
        let document = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let directory = document[0]
        
        return directory
    }
    
    @objc func addImagePressed(){
        //let vc = UIImagePickerController()
        self.vc.modalPresentationStyle = .popover
        navigationController?.present(vc, animated: true)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        addNewMemory(image: image!)
        loadMemories()
        
        dismiss(animated: true)
    }
    
    func addNewMemory(image: UIImage){
        let memoryName = "memory-\(Date().timeIntervalSince1970)"
        
        let imageName = "\(memoryName).jpg"
        let thumbName = "\(memoryName).thumb"
        
        do{
            let imagePath = getDocumentDirectory().appendingPathComponent(imageName)
            
            if let jpegData = UIImageJPEGRepresentation(image, 80){
                try jpegData.write(to: imagePath, options: .atomicWrite)
            }
            
            if let thumbnail = resizeImage(image: image, to: 200){
                let thumbPath = getDocumentDirectory().appendingPathComponent(thumbName)
                
                if let jpegData = UIImageJPEGRepresentation(thumbnail, 80){
                    try jpegData.write(to: thumbPath, options: .atomicWrite)
                }
                
            }
        }catch{
            print("A ocurrido un error al añadir la nueva memoria en el disco")
        }
    }
    
    // Escala la imagen para poder utilizarla como thumbnail
    func resizeImage(image: UIImage, to width: CGFloat) -> UIImage?{
        let scaleFactor = width / image.size.width
        
        let height = image.size.height * scaleFactor
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 0)
        image.draw(in: CGRect(x:0, y:0, width: width, height : height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func imageName(for memory: URL) -> URL {
        return memory.appendingPathExtension("jpg")
    }
    
    func thumbnailName(for memory: URL) -> URL {
        return memory.appendingPathExtension("thumb")
    }
    
    func AudioName(for memory: URL) -> URL {
        return memory.appendingPathExtension("m4a")
    }
    
    func speechName(for memory: URL) -> URL {
        return memory.appendingPathExtension("txt")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if section == 0{
            return 0
        }else{
            return self.memories.count
        }
        
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MemoryCell
        
        let memory = self.memories[indexPath.row]
        let memoryName = self.thumbnailName(for: memory).path
        let image = UIImage(contentsOfFile: memoryName)
        
        cell.memoryImage.image = image
        // Configure the cell
        return cell
    }
    
    // Hace que se muestre la barra de buscar en el view controller
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
        return header
    }
    
    // Hace que solo muestre la barra de busqueda en la seccion 0, y no en cada collectionView
    // Se ocupó agregar la clase UICollectionViewDelegateFlowLayout para que se ejecutara la funcion
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize{
        if section == 0{
            return CGSize(width: 0, height: 50)
        }else{
            return CGSize.zero
        }
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
