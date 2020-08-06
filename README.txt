# Tanks for CoD2

Clientside files are needed for running this.

Version: 001

Stay updated and download the latest version here: [killtube.org](http://killtube.org/showthread.php?1624-DOWNLOAD-COD2-TANKs&p=7572#post7572)

Happy killing, cheers :3li

## Setup

- This script is called from:
  - File: `maps\mp\gametypes\_callbacksetup.gsc`
  - Function: `CodeCallback_StartGameType()`
  - Call: `level thread serthy\main::init();`
- The Model was taken from: http://tf3dm.com/3d-model/abrams-tank-17774.html

### TODO
*		# huds										
*	[ ]		> target hud							
*	[ ]		> tank hud + damage + rotation			
*		# sound										
*	[ ]		> idle									
*	[ ]		> fire									
*	[ ]		> rotation								
*	[ ]		> drive									
*	[ ]		> drive backwards						
*		# damage									
*	[ ]		> hud									
*	[ ]		> fx									
*	[ ]		> logic									
*	[ ]		> respawn								
*	[ ]		> explosion								
*		# spawning									
*	[ ]		> team logic							
*	[ ]		> alignment								
*		# devgui									
*	[ ]		> manual spawn setup					
*	[ ]		> debug lines							
*		# fx										
*	[ ]		> damage								
*	[ ]		> drive									
*	[ ]		> shot									
*	[ ]		> impact								
*		# gun rotation								
*	[ ]		> check if its worth the coding	
*		# anim								
*	[ ]		> fake shot anim if its worth
*		# radiusdamage								
*	[ ]		> implement scriptedradiusdamage	
*		# model
*	[ ]		> add tags
*	[ ]		> fix track blend issue
*	[ ]		> combine tracks and body if no more anim is needed
*	[ ]		> modify gun model ifrotation issue isnt solved		
