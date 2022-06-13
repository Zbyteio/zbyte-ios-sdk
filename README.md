# About ZByte Platform

The ZByte Platform helps you to manage your NFT's.



## Step1 : Import SDK file


```bash
import ZByteSDK
```

## Step2 : Initialise ZByteView

```swift
import ZByteSDK

# initialise ZByteview
let zView = ZByteView();

# add as subview 'geese'
self.view.addSubview(zView);

```

## Step3: Set Dimension


#### Option 1 : Set constraints

```
zView.translatesAutoresizingMaskIntoConstraints = false
zView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true;
zView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true;
zView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true;
zView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true;
```

#### Option 2: Set Frame
```
zView.frame = self.view.bounds
```
