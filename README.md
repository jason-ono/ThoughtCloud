# ThoughtCloud

ThoughtCloud is an iOS app that provides a visual representation of text input. It **processes text data into an interactive 3D sphere model** made of the **most frequently used words** in the text input.

## How it works

![Sample](https://github.com/jason-ono/Story/blob/master/clippo.gif?raw=true)
<br />
<br />
An example with [my article for the Cavalier Daily](https://www.cavalierdaily.com/article/2019/10/im-forgetting-my-mother-tongue)

<br />

ThoughtCloud stores text data and the 3D sphere model is **generated at runtime** based on the text input. Users can store text entries by category. 

I created this app **without using the Interface Builder**. All features have been implemented programmatically.

The exact process of converting text data into a visual model is as **shown below**:

<br />

![Sample](https://github.com/jason-ono/Story/blob/master/Screen%20Shot%202020-09-21%20at%2020.32.20.png?raw=true)

## Background

I created ThoughtCloud as a framework of a larger NLP app project, which is in progress. 

This was my first project using Swift, so I also implemented a wide range of popular frameworks/functions in iOS development for my learning, as listed below.

Feel free to take snippets of my code, especially if you're looking for a sample code for **AutoLayout** and **CoreData**.

* Data Management
    * **CoreData**
* Text Processing
    * **Natural Language**
* UI Frameworks
    * **Auto Layout**
    * **UINavigationController**
    * **UITableView**
    * and more...

For the 3D spherical tag cloud view, I used **[DBSphereTagCloudSwift](https://github.com/apparition47/DBSphereTagCloudSwift)** by [@apparition47](https://github.com/apparition47) and [@dongxinb](https://github.com/dongxinb) (the developer of the original framework initially written in Objective-C).

## License
[MIT](https://choosealicense.com/licenses/mit/)
