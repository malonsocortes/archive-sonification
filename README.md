# archive-sonification
This is a simple first approach to a Processing program that chooses images from one's archive, based on the microphone input amplitude levels, and then transforms that image into sound using a saw oscillator and pink noise.

This program was created to be the object on an introductory video to present myself to the open call Lab 01 Medios Sintientes at MediaLab Matadero Madrid. The idea was to have a conversation with the computer, in which one's voice is the inspiration for the computer to choose an image, and then it goes beyond that and transforms it into sounds. Even though the computer action's and decissions are programmed and determined, we as humans get lost in them and if we let go, we can then discover interesting and surprising actions.

To use this program you need to add a "data" folder (this will be the archive) at the same level of the .pde file, and save in it all the images you want to use. You need Processing 3+ to run. You also sould change the input channel depending on what you want to use as input. Then press Run: images will start appearing as the audio input starts running. If you click on the screen the program will start making sounds from those images. Each image is shown for a random number of seconds between 1 and 4. For each second, a sound is produced.

The conde and it's performance still has a lot of room for improvement (this was programmed in 1 day, this beign the first time I trully used Processing). I would like to make more complicated and more "natural" mappings between the sounds (input or output) and the images. By natural I mean that, for example, instead of mapping pixel possition to frequency and amplitude and its mean RGB color to the add on, I could program an approach based on distributions of the three RGB channels, so that sound frequencies depend on this distributions so that images with more even distributions produce more similar sounds, whereas noisy images produce rarer sounds.
