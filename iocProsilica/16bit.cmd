
# Use this line if you only want to use the Prosilica in 8-bit mode.  It uses an 8-bit waveform record
# NELEMENTS is set large enough for a 1360x1024x3 image size, which is the number of pixels in RGB images from the GC1380CH color camera. 
# Must be at least as big as the maximum size of your camera images

dbLoadRecords("$(ADCORE)/db/NDStdArrays.template", "P=$(PREFIX),R=image1:,PORT=Image1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=$(PORT),TYPE=Int16,FTVL=SHORT,NELEMENTS=$(NPIXELS)")
