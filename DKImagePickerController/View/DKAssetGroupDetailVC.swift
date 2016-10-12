//
//  DKAssetGroupDetailVC.swift
//  DKImagePickerController
//
//  Created by ZhangAo on 15/8/10.
//  Copyright (c) 2015年 ZhangAo. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

private let DKImageCameraIdentifier = "DKImageCameraIdentifier"
private let DKImageAssetIdentifier = "DKImageAssetIdentifier"
private let DKMediaAssetIdentifier = "DKMediaAssetIdentifier"

// Show all images in the asset group
internal class DKAssetGroupDetailVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, DKGroupDataManagerObserver {

    class DKImageCameraCell: UICollectionViewCell {
        
        var didCameraButtonClicked: (() -> Void)?
		
		private weak var cameraButton: UIButton!
		
		override init(frame: CGRect) {
			super.init(frame: frame)
			
			let cameraButton = UIButton(frame: frame)
			cameraButton.addTarget(self, action: #selector(DKImageCameraCell.cameraButtonClicked), forControlEvents: .TouchUpInside)
			cameraButton.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
			self.contentView.addSubview(cameraButton)
			self.cameraButton = cameraButton
			
			self.contentView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
		}
		
		required init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		func setCameraImage(cameraImage: UIImage) {
			self.cameraButton.setImage(cameraImage, forState: .Normal)
		}
		
        func cameraButtonClicked() {
            if let didCameraButtonClicked = self.didCameraButtonClicked {
                didCameraButtonClicked()
            }
        }
        
    } /* DKImageCameraCell */

    
    class DKAssetCell: UICollectionViewCell {
        internal var checkedBackgroundColor:UIColor?
        internal var uncheckedBackgroundColor:UIColor?

        class DKImageCheckView: UIView {

            internal lazy var checkImageView: UIImageView = {
                let imageView = UIImageView()
                return imageView
            }()
            
            internal lazy var checkLabel: UILabel = {
                let label = UILabel()
                label.textAlignment = .Right
                
                return label
            }()
            
            override init(frame: CGRect) {
                super.init(frame: frame)
                
                self.addSubview(checkImageView)
                self.addSubview(checkLabel)
            }

            required init?(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            override func layoutSubviews() {
                super.layoutSubviews()
                
                self.checkImageView.frame = self.bounds
                self.checkLabel.frame = CGRect(x: 0, y: 5, width: self.bounds.width - 5, height: 20)
            }
            
        } /* DKImageCheckView */
		
		private var asset: DKAsset!
		
        private let thumbnailImageView: UIImageView = {
            let thumbnailImageView = UIImageView()
            thumbnailImageView.contentMode = .ScaleAspectFill
            thumbnailImageView.clipsToBounds = true
            
            return thumbnailImageView
        }()
        
        private let checkView = DKImageCheckView()
        
        override var selected: Bool {
            didSet {
                checkView.hidden = !super.selected
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.thumbnailImageView.frame = self.bounds
            self.contentView.addSubview(self.thumbnailImageView)
            self.contentView.addSubview(checkView)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
			
            self.thumbnailImageView.frame = self.bounds
            checkView.frame = self.thumbnailImageView.frame
        }
		
    } /* DKAssetCell */

    private static let TagForDurationLabel:Int = 1
    private static let TagForIconImageView:Int = 2

    class DKMediaAssetCell: DKAssetCell {

        override var asset: DKAsset! {
			didSet {
                let videoDurationLabel = self.videoInfoView.viewWithTag(TagForDurationLabel) as! UILabel
                if self.asset.duration>0 {
                    let minutes: Int = Int(asset.duration!) / 60
                    let seconds: Int = Int(round(asset.duration!)) % 60
                    videoDurationLabel.text = String(format: "\(minutes):%02d", seconds)
                    videoDurationLabel.hidden = false
                }else{
                    videoDurationLabel.text = nil
                    videoDurationLabel.hidden = true
                }
			}
		}

        private var assetIconImage: UIImage? {
            didSet {
                self.videoInfoView.hidden = self.assetIconImage == nil
                (self.videoInfoView.viewWithTag(TagForIconImageView) as! UIImageView).image = self.assetIconImage
            }
        }
		
        override var selected: Bool {
            didSet {
                if super.selected {
                    self.videoInfoView.backgroundColor = self.checkedBackgroundColor ?? UIColor(red: 20 / 255, green: 129 / 255, blue: 252 / 255, alpha: 1)
                } else {
                    self.videoInfoView.backgroundColor = self.uncheckedBackgroundColor ?? UIColor(white: 0.0, alpha: 0.7)
                }
            }
        }
        
        private lazy var videoInfoView: UIView = {
            let mediaInfoView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 0))

            let mediaIconImageView = UIImageView(image: DKImageResource.videoCameraIcon())
            mediaIconImageView.tag = TagForIconImageView
            mediaInfoView.addSubview(mediaIconImageView)
            mediaIconImageView.center = CGPoint(x: mediaIconImageView.bounds.width / 2 + 7, y: mediaInfoView.bounds.height / 2)
            mediaIconImageView.autoresizingMask = [.FlexibleBottomMargin, .FlexibleTopMargin]
            mediaIconImageView.contentMode = .ScaleAspectFit
            
            let videoDurationLabel = UILabel()
            videoDurationLabel.tag = TagForDurationLabel
            videoDurationLabel.textAlignment = .Right
            videoDurationLabel.font = UIFont.systemFontOfSize(12)
            videoDurationLabel.textColor = UIColor.whiteColor()
            mediaInfoView.addSubview(videoDurationLabel)
            videoDurationLabel.frame = CGRect(x: 0, y: 0, width: mediaInfoView.bounds.width - 7, height: mediaInfoView.bounds.height)
            videoDurationLabel.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            
            return mediaInfoView
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.contentView.addSubview(videoInfoView)
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            let height: CGFloat = 30
            self.videoInfoView.frame = CGRect(x: 0, y: self.contentView.bounds.height - height,
                width: self.contentView.bounds.width, height: height)
        }
        
    } /* DKMediaAssetCell */
	
    private lazy var selectGroupButton: UIButton = {
        let button = UIButton()
		
		let globalTitleColor = UINavigationBar.appearance().titleTextAttributes?[NSForegroundColorAttributeName] as? UIColor
		button.setTitleColor(globalTitleColor ?? UIColor.blackColor(), forState: .Normal)

		let globalTitleFont = UINavigationBar.appearance().titleTextAttributes?[NSFontAttributeName] as? UIFont
		button.titleLabel!.font = globalTitleFont ?? UIFont.systemFontOfSize(18.0)

		button.addTarget(self, action: #selector(DKAssetGroupDetailVC.showGroupSelector), forControlEvents: .TouchUpInside)
        return button
    }()
		
    internal var selectedGroupId: String?
	
	internal weak var imagePickerController: DKImagePickerController!
	
	private var groupListVC: DKAssetGroupListVC!
    
    private var hidesCamera: Bool = false
	
	internal var collectionView: UICollectionView!
    
	private var footerView: UIView?
	
	private var currentViewSize: CGSize!
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		
		if let currentViewSize = self.currentViewSize where CGSizeEqualToSize(currentViewSize, self.view.bounds.size) {
			return
		} else {
			currentViewSize = self.view.bounds.size
		}

		self.collectionView?.collectionViewLayout.invalidateLayout()
	}
	
	private lazy var groupImageRequestOptions: PHImageRequestOptions = {
		let options = PHImageRequestOptions()
		options.deliveryMode = .Opportunistic
		options.resizeMode = .Fast
        return options
	}()
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let layout = self.imagePickerController.UIDelegate.layoutForImagePickerController(self.imagePickerController).init()
		self.collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        self.collectionView.backgroundColor = UICollectionView.appearance().backgroundColor
            ?? self.imagePickerController.UIDelegate.imagePickerControllerCollectionViewBackgroundColor()
        self.collectionView.allowsMultipleSelection = true
		self.collectionView.delegate = self
		self.collectionView.dataSource = self
        self.collectionView.registerClass(DKImageCameraCell.self, forCellWithReuseIdentifier: DKImageCameraIdentifier)
        self.collectionView.registerClass(DKAssetCell.self, forCellWithReuseIdentifier: DKImageAssetIdentifier)
        self.collectionView.registerClass(DKMediaAssetCell.self, forCellWithReuseIdentifier: DKMediaAssetIdentifier)
		self.view.addSubview(self.collectionView)
		
		self.footerView = self.imagePickerController.UIDelegate.imagePickerControllerFooterView(self.imagePickerController)
		if let footerView = self.footerView {
			self.view.addSubview(footerView)
		}
		
		self.hidesCamera = self.imagePickerController.sourceType == .Photo
		self.checkPhotoPermission()
    }
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		if let footerView = self.footerView {
			footerView.frame = CGRectMake(0, self.view.bounds.height - footerView.bounds.height, self.view.bounds.width, footerView.bounds.height)
			self.collectionView.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height - footerView.bounds.height)
			
		} else {
			self.collectionView.frame = self.view.bounds
		}
	}
	
    func invalidateContents(){
        self.selectGroupButton.setAttributedTitle(nil, forState: .Normal)

        for cell:DKAssetCell in self.collectionView?.visibleCells() as! [DKAssetCell] {
            cell.thumbnailImageView.image = nil
            cell.checkView.checkImageView.image = nil;
            if cell is DKMediaAssetCell{
                (cell as? DKMediaAssetCell)?.assetIconImage = nil
            }
        }

        DKImageManager.sharedInstance.invalidateCaches()
        self.invalidateCaches(false)
    }

    func invalidateCaches(fromMemoryWarning:Bool){
        self.invalidateCachedStaticResources()
        self.invalidateCachedAssetsOfCurrentGroup()

        if fromMemoryWarning{
            self.cachedThumbnailImages = nil
        }
    }

    func invalidateCachedStaticResources(){
        self.cachedCheckedImage = nil
        self.cachedPhotoIconInfo = nil
        self.cachedLivePhotoIconInfo = nil
        self.cachedVideoIconInfo = nil
    }

    func invalidateCachedAssetsOfCurrentGroup(){
        self.cachedAssets = nil
        self.cachedGroups = nil
    }

	internal func checkPhotoPermission() {
		func photoDenied() {
			self.view.addSubview(DKPermissionView.permissionView(.Photo))
			self.view.backgroundColor = UIColor.blackColor()
			self.collectionView?.hidden = true
		}
		
		func setup() {
			getImageManager().groupDataManager.addObserver(self)
			self.groupListVC = DKAssetGroupListVC(selectedGroupDidChangeBlock: { [unowned self] groupId in
				self.selectAssetGroup(groupId)
			}, defaultAssetGroup: self.imagePickerController.defaultAssetGroup)

            let style = DKAssetGroupCellStyle()
            style.separatorLineColor = self.imagePickerController.UIDelegate.imagePickerControllerAlbumSelectListSeparatorColor()
            style.countLabelColor = self.imagePickerController.UIDelegate.imagePickerControllerAlbumSelectListCountLabelTextColor()
            style.nameLabelColor = self.imagePickerController.UIDelegate.imagePickerControllerAlbumSelectListNameLabelTextColor()
            style.checkedIconImage = self.imagePickerController.UIDelegate.imagePickerControllerAlbumSelectListCheckedIconImage()
            style.checkedIconTintColor = self.imagePickerController.UIDelegate.imagePickerControllerAlbumSelectListTCheckedIconImageTintColor()

            self.groupListVC.groupListCellStyle = style
			self.groupListVC.loadGroups()
		}
		
		DKImageManager.checkPhotoPermission { granted in
			granted ? setup() : photoDenied()
		}
	}
	
    func selectAssetGroup(groupId: String?) {
        if self.selectedGroupId == groupId {
            return
        }

        self.selectedGroupId = groupId

        self.reloadCollectionViews()
    }

    func reloadAllCurrentGroupData() {
        getImageManager().invalidate()

        self.groupListVC.loadGroups()
        self.groupListVC.tableView.reloadData()

        self.reloadCollectionViews()
    }

    func reloadCollectionViews(){
        self.updateTitleView()

        if(self.imagePickerController.deselectAllWhenChangingAlbum
                || self.imagePickerController.allowCirculatingSelection){
            self.imagePickerController.deselectAllAssets(false)
        }
        self.invalidateCachedAssetsOfCurrentGroup()
        self.collectionView!.reloadData()
    }
	
	func updateTitleView() {
		let group = getImageManager().groupDataManager.fetchGroupWithGroupId(self.selectedGroupId!)
		self.title = group.groupName
		
		let groupsCount = getImageManager().groupDataManager.groupIds?.count

        if groupsCount > 1{
            //create pretty arrow
            let addingDownArrowStr = "  \u{FE40}"
            let originalFont = self.selectGroupButton.titleLabel!.font

            self.selectGroupButton.setAttributedTitle(nil, forState: .Normal)
            self.selectGroupButton.setTitle(group.groupName + addingDownArrowStr, forState: .Normal)
            let attributedString = NSMutableAttributedString(attributedString: (self.selectGroupButton.titleLabel?.attributedText)!)
            let rangeToApply = NSRange(location: attributedString.string.characters.count-addingDownArrowStr.characters.count, length: addingDownArrowStr.characters.count)
            //To beautify overall, like the Apple music app's, size, baseline offset and kerning of the arrow symbol should be smaller than label.
            attributedString.enumerateAttribute(NSFontAttributeName, inRange:rangeToApply, options:.LongestEffectiveRangeNotRequired,
                    usingBlock: { value, range, stop in
                        let font = value as! UIFont
                        attributedString.addAttribute(NSFontAttributeName, value:font.fontWithSize(originalFont.pointSize/1.5), range:range)
                    })
            attributedString.addAttribute(NSBaselineOffsetAttributeName, value: -2.5, range: rangeToApply)
            attributedString.addAttribute(NSKernAttributeName, value: -1.5, range: rangeToApply)
            self.selectGroupButton.setAttributedTitle(attributedString, forState: .Normal)
            self.selectGroupButton.titleEdgeInsets = UIEdgeInsetsMake(3, 0, 0, 0)
        }else{
            self.selectGroupButton.setTitle(group.groupName, forState: .Normal)
            self.selectGroupButton.titleEdgeInsets = UIEdgeInsetsZero
        }

        self.selectGroupButton.sizeToFit()
		self.selectGroupButton.enabled = groupsCount > 1
		
		self.navigationItem.titleView = self.selectGroupButton
	}
    
    func showGroupSelector() {
        DKPopoverViewController.popoverViewController(self.groupListVC, fromView: self.selectGroupButton)
    }
	
    // MARK: - Cells

    func cameraCellForIndexPath(indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView!.dequeueReusableCellWithReuseIdentifier(DKImageCameraIdentifier, forIndexPath: indexPath) as! DKImageCameraCell
		cell.setCameraImage(self.imagePickerController.UIDelegate.imagePickerControllerCameraImage())
        
        cell.didCameraButtonClicked = { [unowned self] in
            if UIImagePickerController.isSourceTypeAvailable(.Camera) {
                if self.imagePickerController.selectedAssets.count < self.imagePickerController.maxSelectableCount  {
                    self.imagePickerController.presentCamera()
                } else {
                    self.imagePickerController.UIDelegate.imagePickerControllerDidReachMaxLimit(self.imagePickerController)
                }
            }
        }

        return cell
	}

    var cachedCheckedImage:UIImage?
    var cachedLivePhotoIconInfo:(String, UIImage?)?
    var cachedPhotoIconInfo:(String, UIImage?)?
    var cachedVideoIconInfo:(String, UIImage?)?
    var cachedGroups:[String:DKAssetGroup]?
    var cachedAssets:[String:[Int:DKAsset]]?
    var cachedThumbnailImages:[String:UIImage]?

    func assetCellForIndexPath(indexPath: NSIndexPath) -> UICollectionViewCell {
		let assetIndex = (indexPath.row - (self.hidesCamera ? 0 : 1))

        if cachedGroups == nil{
            cachedGroups = [:]
        }
        if cachedGroups!.indexForKey(self.selectedGroupId!) == nil{
           self.cachedGroups![self.selectedGroupId!] = getImageManager().groupDataManager.fetchGroupWithGroupId(self.selectedGroupId!)
        }
		let group = cachedGroups![self.selectedGroupId!]!
		
        if cachedAssets == nil{
            cachedAssets = [:]
        }
        if cachedAssets!.indexForKey(group.groupId) == nil{
            self.cachedAssets![group.groupId] = [:]
        }
        if self.cachedAssets![group.groupId]!.indexForKey(assetIndex) == nil{
            self.cachedAssets![group.groupId]![assetIndex] = getImageManager().groupDataManager.fetchAssetWithGroup(group, index: assetIndex)
        }
		let asset:DKAsset = self.cachedAssets![group.groupId]![assetIndex]!
		
		var cell: DKAssetCell!

        let cellSettingsByAsset:(String, UIImage?) = self.cellSettingsByAsset(asset)
        let identifier: String! = cellSettingsByAsset.0
        let assetIconImage:UIImage? = cellSettingsByAsset.1

        //configure initial cell appearance
        cell = self.collectionView!.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! DKAssetCell
        cell.checkView.checkImageView.tintColor = self.imagePickerController.UIDelegate.imagePickerControllerCheckedImageTintColor()
        cell.checkView.checkImageView.image = self.cellCheckedImage()
        cell.checkedBackgroundColor = self.imagePickerController.UIDelegate.imagePickerControllerCheckedBackgroundColor()
        cell.uncheckedBackgroundColor = self.imagePickerController.UIDelegate.imagePickerControllerUnCheckedBackgroundColor()
        cell.checkView.checkLabel.hidden = self.imagePickerController.UIDelegate.imagePickerControllerCheckedNumberHidden()
        cell.checkView.checkLabel.font = self.imagePickerController.UIDelegate.imagePickerControllerCheckedNumberFont()
        cell.checkView.checkLabel.textColor = self.imagePickerController.UIDelegate.imagePickerControllerCheckedNumberColor()

        //set asset's icon image
        (cell as? DKMediaAssetCell)?.assetIconImage = assetIconImage

        cell.asset = asset

		let tag = indexPath.row + 1
		cell.tag = tag
		
		let itemSize = self.collectionView!.collectionViewLayout.layoutAttributesForItemAtIndexPath(indexPath)!.size

        if cachedThumbnailImages==nil{
            cachedThumbnailImages = [:]
        }
        if cachedThumbnailImages!.indexForKey((asset.originalAsset?.localIdentifier)!) == nil{
            //FIXME: huge memory leaks. but why? it just uses pure ios api.
            asset.fetchImageWithSize(itemSize.toPixel(), options: self.groupImageRequestOptions, contentMode: .AspectFill) { (image, info) in
                if cell.tag == tag {
                    cell.thumbnailImageView.image = image
                }
                self.cachedThumbnailImages![(asset.originalAsset?.localIdentifier)!] = image
            }
        }else{
            cell.thumbnailImageView.image = self.cachedThumbnailImages![(asset.originalAsset?.localIdentifier)!]
        }
		
		if let index = self.imagePickerController.selectedAssets.indexOf(asset) {
			cell.selected = true
			cell.checkView.checkLabel.text = "\(index + 1)"
			self.collectionView!.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition.None)
		} else {
			cell.selected = false
			self.collectionView!.deselectItemAtIndexPath(indexPath, animated: false)
		}
		
		return cell
	}

    func cellCheckedImage() -> UIImage?{
        if cachedCheckedImage == nil{
            cachedCheckedImage = (self.imagePickerController.UIDelegate.imagePickerControllerCheckedImage()
                    ?? DKImageResource.checkedImage()).imageWithRenderingMode(.AlwaysTemplate)
        }
        return cachedCheckedImage
    }

    func cellSettingsByAsset(asset: DKAsset) -> (String, UIImage?) {
        let originalAsset = asset.originalAsset!
        switch (originalAsset.mediaType, originalAsset.mediaSubtypes){
        case let (.Image, x) where x.contains(.PhotoLive): //Live Photo
            if self.cachedLivePhotoIconInfo == nil{
                self.cachedLivePhotoIconInfo = (
                        DKMediaAssetIdentifier,
                        self.imagePickerController.UIDelegate.imagePickerControllerAssetLivePhotoIconImage()
                        )
            }
            return self.cachedLivePhotoIconInfo!
            
        case (.Image, _):
            if self.cachedPhotoIconInfo == nil{
                self.cachedPhotoIconInfo = (
                        DKImageAssetIdentifier,
                        self.imagePickerController.UIDelegate.imagePickerControllerAssetPhotoIconImage()
                        )
            }
            return self.cachedPhotoIconInfo!

        case (.Video, _):
            if self.cachedVideoIconInfo == nil{
                self.cachedVideoIconInfo = (
                        DKMediaAssetIdentifier,
                        self.imagePickerController.UIDelegate.imagePickerControllerAssetVideoIconImage()
                                ?? DKImageResource.videoCameraIcon()
                        )
            }
            return self.cachedVideoIconInfo!

        default:
            return (DKImageAssetIdentifier, nil)
        }
    }

    // MARK: - UICollectionViewDelegate, UICollectionViewDataSource methods

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let selectedGroup = self.selectedGroupId else { return 0 }
		
		let group = getImageManager().groupDataManager.fetchGroupWithGroupId(selectedGroup)
        return (group.totalCount ?? 0) + (self.hidesCamera ? 0 : 1)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 && !self.hidesCamera {
            return self.cameraCellForIndexPath(indexPath)
        } else {
            return self.assetCellForIndexPath(indexPath)
        }
    }
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let firstSelectedAsset = self.imagePickerController.selectedAssets.first,
            selectedAsset = (collectionView.cellForItemAtIndexPath(indexPath) as? DKAssetCell)?.asset
            where self.imagePickerController.allowMultipleTypes == false && firstSelectedAsset.isVideo != selectedAsset.isVideo {

            let alert = UIAlertController(
                    title: DKImageLocalizedStringWithKey("selectPhotosOrVideos")
                    , message: DKImageLocalizedStringWithKey("selectPhotosOrVideosError")
                    , preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: DKImageLocalizedStringWithKey("ok"), style: .Cancel) { _ in })
            self.imagePickerController.presentViewController(alert, animated: true){}

            return false
        }
		
        let didReachMaxSelectableCount = self.imagePickerController.selectedAssets.count >= self.imagePickerController.maxSelectableCount
        if didReachMaxSelectableCount {
            if self.imagePickerController.allowCirculatingSelection {
                let currentSelectedIndexPaths:[NSIndexPath] = collectionView.indexPathsForSelectedItems()!
                let firstSelectedIndexPath:NSIndexPath = currentSelectedIndexPaths.first!
                if let removingAsset:DKAsset = (collectionView.cellForItemAtIndexPath(firstSelectedIndexPath) as! DKAssetCell).asset{
                    self.imagePickerController.deselectImage(removingAsset)
                }
                UIView.performWithoutAnimation({
                    collectionView.reloadItemsAtIndexPaths(currentSelectedIndexPaths)
                })
                return true
                
            }else{
                self.imagePickerController.UIDelegate.imagePickerControllerDidReachMaxLimit(self.imagePickerController)
                return false
            }
        }
        
        return true
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		let selectedAsset = (collectionView.cellForItemAtIndexPath(indexPath) as? DKAssetCell)?.asset
		self.imagePickerController.selectImage(selectedAsset!)
        
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? DKAssetCell {
            cell.checkView.checkLabel.text = "\(self.imagePickerController.selectedAssets.count)"
        }
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
		if let removedAsset = (collectionView.cellForItemAtIndexPath(indexPath) as? DKAssetCell)?.asset {
			let removedIndex = self.imagePickerController.selectedAssets.indexOf(removedAsset)!
			
			/// Minimize the number of cycles.
			let indexPathsForSelectedItems = collectionView.indexPathsForSelectedItems() as [NSIndexPath]!
			let indexPathsForVisibleItems = collectionView.indexPathsForVisibleItems()
			
			let intersect = Set(indexPathsForVisibleItems).intersect(Set(indexPathsForSelectedItems))
			
			for selectedIndexPath in intersect {
				if let selectedCell = (collectionView.cellForItemAtIndexPath(selectedIndexPath) as? DKAssetCell) {
					let selectedIndex = self.imagePickerController.selectedAssets.indexOf(selectedCell.asset)!
					
					if selectedIndex > removedIndex {
						selectedCell.checkView.checkLabel.text = "\(Int(selectedCell.checkView.checkLabel.text!)! - 1)"
					}
				}
			}
			
			self.imagePickerController.deselectImage(removedAsset)
		}
    }
	
	// MARK: - DKGroupDataManagerObserver methods
	
	func groupDidUpdate(groupId: String) {
		if self.selectedGroupId == groupId {
			self.updateTitleView()
		}
	}
	
	func group(groupId: String, didRemoveAssets assets: [DKAsset]) {
		for (_, selectedAsset) in self.imagePickerController.selectedAssets.enumerate() {
			for removedAsset in assets {
				if selectedAsset.isEqual(removedAsset) {
					self.imagePickerController.deselectImage(selectedAsset)
				}
			}
		}
		if self.selectedGroupId == groupId {
            self.invalidateCachedAssetsOfCurrentGroup()
			self.collectionView?.reloadData()
		}
	}
	
	func group(groupId: String, didInsertAssets assets: [DKAsset]) {
        self.invalidateCachedAssetsOfCurrentGroup()
		self.collectionView?.reloadData()
	}

}
