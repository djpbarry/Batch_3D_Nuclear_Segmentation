ext = ".tif";

deconFolder = getDirectory("Choose directory for deconvolved images");
rawFolder = getDirectory("Choose directory for raw intensities");
outputFolder = getDirectory("Choose a directory for outputs");

setBatchMode(true);

deconFiles = getFileList(deconFolder);
rawFiles = getFileList(rawFolder);

Array.sort(deconFiles);
Array.sort(rawFiles);

for (i = 0; i < rawFiles.length; i++) {
	if(endsWith(rawFiles[i], ext)){
		deconFileIndex = getDeconFileIndex(rawFiles[i], deconFiles, ext);
		if(deconFileIndex > -1){
			print("Analysing " +  deconFiles[deconFileIndex]);
			open(deconFolder + File.separator + deconFiles[deconFileIndex]);
			deconTitle = getTitle();
			run("32-bit");
			run("Gaussian Blur 3D...", "x=1 y=1 z=0.5");
			setAutoThreshold("Huang dark stack");
			setOption("BlackBackground", true);
			run("Convert to Mask", "method=Huang background=Dark");
			mask = getTitle();
			run("3D Watershed Split", "binary=" + removeFileExtension(deconTitle, ext) + " seeds=Automatic radius=3");
			watershed = getTitle();
			open(rawFolder + File.separator + rawFiles[i]);
			rawTitle = getTitle();
			run("3D OC Options", "volume surface nb_of_obj._voxels nb_of_surf._voxels integrated_density mean_gray_value std_dev_gray_value median_gray_value minimum_gray_value maximum_gray_value centroid mean_distance_to_surface std_dev_distance_to_surface median_distance_to_surface centre_of_mass bounding_box dots_size=5 font_size=10 show_numbers white_numbers store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=" + rawFiles[i]);
			selectWindow(watershed);
			run("3D Objects Counter", "threshold=1 slice=20 min.=100 max.=2000 objects statistics summary");
			saveTitle = replace(rawTitle, "\\", "_");
			saveAs("Tiff", outputFolder + File.separator + "Objects map of " + saveTitle);
			saveAs("Results", outputFolder + File.separator + saveTitle + ".csv");
			close("*");
		}
	}
}

setBatchMode(false);

function removeFileExtension(filename, ext){
	index = lastIndexOf(filename, ext);
	return substring(filename, 0, index);
}

function getDeconFileIndex(rawFile, deconFiles, ext){
	for(i = 0; i < deconFiles.length; i++){
		if(startsWith(deconFiles[i], rawFile) && endsWith(deconFiles[i], ext)){
			return i;
		}
	}
	return -1;
}
