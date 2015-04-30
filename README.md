# StackManager
![alt tag](https://raw.githubusercontent.com/mariohahn/StackManager/master/StackManager/Images/StackManager.gif)

## Podfile

```ruby
platform :ios, '7.0'
pod 'MHStackManager'
```

##Usage

```objective-c
  StackManager *manager = [StackManager.alloc initWithViewController:self];
  [self.manager presentViewController:yourViewController];

```
