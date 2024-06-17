//Program to filter and analyse nanoparticles using FIJI.
//It opens a directory where you can select your image and it process it.
//The program returns a binary image of the mask of the particles, the analyse particles locations and the results
//...
//Creator: Dr Laia Pasquina-Lemonche (cc) October 2023 - University of Sheffield

//Clean up the roi manager from previous runs of the program on different images
	if (roiManager("count")>0) {
		roiManager("Deselect");
		roiManager("Delete");
		run("Close");
	}
	
run("Close All");

print("     ");
print("Welcome to the program to analyse nanoparticles. Now you will need to select your image.");
print("    ");

//This is the command to open the folder finder, you select the image and click Open
open();

//Define a variable that captures the name of the image, this will make it be useful for any image.
fileName = File.nameWithoutExtension;

//setOption("ScaleConversions", true);

//Convert image to 8 bit so it can be thresholded.
run("8-bit");

//This is a set of filterings that help detect the nanoparticles better
run("Subtract Background...", "rolling=500 light");
run("Despeckle");
run("Remove Outliers...", "radius=10 threshold=50 which=Bright");
run("Mean...", "radius=4");

//threshold image (image in binary slices where the areas where there is no material are considered pores).
setAutoThreshold("Otsu dark");

//This selects the colour of your backgroun (try both putting true or false here)
setOption("BlackBackground", false);
run("Threshold...");

//Halts the macro so the user can select the best threshol. The macro proceeds when the user clicks "OK" or it is aborted if the user clicks on "Cancel"
waitForUser("Drag the cursor in the threshold window \n select an option that makes the particles red, when you finish click OK."); 

//This creates the mask
run("Convert to Mask");

print("     ");
print("The thresholding finish. Now select the folder where you want to save the mask and the results.");
print("    ");

//This changes the masks colour order (white to black)
setThreshold(0, 254);
run("Convert to Mask");


//Select folder where your masked image and the analysis results will be saved. 
dir1 = getDirectory("Choose Directory where the binary image adn results will be saved"); 

//Save binary image
saveAs("tiff", dir1+fileName+"_binary");

//The following commands clean the binary image to analyse it better.
run("Remove Outliers...", "radius=10 threshold=50 which=Bright");
run("Fill Holes");
run("Watershed");
run("Erode");

//Save filtered binary image
saveAs("tiff", dir1+fileName+"_binary_filtered");

//Now there is going to be a dialog box so the user can optimise the best options for analyse particles
  //define the variables to be chosen by the user

  Min_size = 100;
  Max_size = 2000;
 
  //This creates the dialog box for the user to enter values
  Dialog.create("Analyse particles limits of size");

  //These are the values and messages in the dialog box
  Dialog.addMessage("The following numbers are in pixels and they represents area. \n if do not know use recommended values to start with");
  Dialog.addNumber("Which minimal size you want?:", Min_size);
  Dialog.addNumber("Which maximal size you want?:", Max_size);
  Dialog.show();
  
  //Get the variables from the dialog box to be used in the program (needs to be done in order)
  Min_size = Dialog.getNumber();
  Max_size = Dialog.getNumber();
   
run("Set Measurements...", "area mean min centroid perimeter bounding fit median redirect=None decimal=3");
run("Analyze Particles...", "size="+Min_size+"-"+Max_size+" show=Outlines display exclude include summarize add");
//selectImage("Drawing of B-HB148 in 1000mM KCl 0.02%-80000.0V-11000X--0050.tif");

//This saves the results tables with all the nanoparticles sizes and parameters
saveAs("Results", dir1+fileName+"_Results.csv");

//find the titles of all images and save image that starts with "Drawing" which contains the outlines of nanoparticles with numbers.
titles = newArray(nImages());
  for (i=1; i<=nImages(); i++) {

    //Get all the titles from the images
    selectImage(i);
    titles[i-1] = getTitle();
    NaM = titles[i-1];

   //Find Drawing image and save it
    A= startsWith(NaM, "Drawing");
    	if(A==1){
		saveAs("tiff", dir1+fileName+"_outlines_with_numbers");
    	}
  	}
  	
  	
run("Close All");

print("     ");
print("The program has finished, click run again to analyse another image.");
print("_____________________________________________________________________");
print("    ");