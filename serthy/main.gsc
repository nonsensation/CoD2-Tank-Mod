

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*						Tanks for CoD2
*
*	Clientside files are needed for running this.
*
*	Version: 001
*
*	Stay updated and download the latest version here:
*		
*
*	Happy killing, cheers Serthy
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*	
*						Serthy
*				
*				xFire: serthy
*				eMail: serthy@ymail.com
*				Steam: the_serth
*				Origin: the_serth
*				YouTube: serthylicious
*	
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*	This script is called from:
*		File:
*			maps\mp\gametypes\_callbacksetup.gsc
*		Function:
*			CodeCallback_StartGameType()
*		Call:
*			level thread serthy\main::init();
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*	The Model was taken from:
*		http://tf3dm.com/3d-model/abrams-tank-17774.html
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*	TODO:
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
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

/*
====================
	init()
====================
*/
init()
{
	level.gametype = getCvar( "g_gametype" );
	level.mapname = getCvar( "mapname" );
	level.dedicated = getCvarInt( "dedicated" );

	if( !isDefined( level.teambased ) )
	{
		gt = level.gametype;

		level.teambased = ( gt != "dm" );
	}

	game["menu_clientcmd"] = "clientcmd";

	precacheMenu( game["menu_clientcmd"] );

	level.tank_allow = cvarDef( "tank_allow" , 1 , 0 , 1 );

	if( !level.tank_allow )
	{
		log( "* * * * * * * * * * * [TANKS DISABLED] * * * * * * * * * * *" );

		return;
	}

	level.tank_debug = cvarDef( "tank_debug" , 0 , 0 , 1 );
	level.tank_count = cvarDef( "tank_count" , 6 , 1 , 10 );
	level.tank_health = cvarDef( "tank_health" , 0 , 0 , 10 );
	level.tank_dmg_min = cvarDef( "tank_dmg_min" , 0 , 0 , 100 ); 
	level.tank_dmg_max = cvarDef( "tank_dmg_max" , 100 , level.tank_dmg_min , 1024 );
	level.tank_dmg_radius = cvarDef( "tank_dmg_radius" , 64 , 64 , 1024 );
	level.tank_dmg_crush = cvarDef( "tank_dmg_crush" , 100 , 100 , 1024 );
	level.tank_perteam = cvarDef( "tank_perteam" , level.teambased , 0 , 1 );

	log( "* * * * * * * * * * * [TANKS ENABLED] * * * * * * * * * * *" );
	log( "*		tank_debug: 		" + level.tank_debug );
	log( "*		tank_count: 		" + level.tank_count );
	log( "*		tank_health: 		" + level.tank_health );
	log( "*		tank_dmg_min: 		" + level.tank_dmg_min );
	log( "*		tank_dmg_max: 		" + level.tank_dmg_max );
	log( "*		tank_dmg_radius: 	" + level.tank_dmg_radius );
	log( "*		tank_dmg_crush: 	" + level.tank_dmg_crush );
	log( "*		tank_perteam: 		" + level.tank_perteam );
	log( "* * * * * * * * * * * * * * * * * * * * * * * * * * * * * *" );

	level._effect["tank_flash"] = loadFx( "fx/muzzleflashes/panzer_flash.efx" );
	level._effect["tank_impact"] = loadFx( "fx/explosions/default_explosion.efx" );
	//level._effect["tank_tracks"] = loadFx( "fx/muzzleflashes/panzer_flash.efx" );
	//level._effect["tank_dmg_small"] = loadFx( "fx/muzzleflashes/panzer_flash.efx" );
	//level._effect["tank_dmg_medium"] = loadFx( "fx/muzzleflashes/panzer_flash.efx" );
	//level._effect["tank_dmg_high"] = loadFx( "fx/muzzleflashes/panzer_flash.efx" );
	//level._effect["tank_explosion"] = loadFx( "fx/muzzleflashes/panzer_flash.efx" );

	level.tank_model_body[0] = "xmodel/serthy_tank_a_body";
	level.tank_model_tower[0] = "xmodel/serthy_tank_a_tower";
	level.tank_model_gun[0] = "xmodel/serthy_tank_a_gun";
	level.tank_model_track[0] = "xmodel/serthy_tank_a_track";
	level.tank_model_track_scroll[0] = "xmodel/serthy_tank_a_track_scroll";

	precacheModel( level.tank_model_body[0] );
	precacheModel( level.tank_model_tower[0] );
	precacheModel( level.tank_model_gun[0] );
	precacheModel( level.tank_model_track[0] );
	precacheModel( level.tank_model_track_scroll[0] );

	level.tank_model_body[1] = "xmodel/serthy_tank_b_body";
	level.tank_model_tower[1] = "xmodel/serthy_tank_b_tower";
	level.tank_model_gun[1] = "xmodel/serthy_tank_b_gun";
	level.tank_model_track[1] = "xmodel/serthy_tank_b_track";
	level.tank_model_track_scroll[1] = "xmodel/serthy_tank_b_track_scroll";

	precacheModel( level.tank_model_body[1] );
	precacheModel( level.tank_model_tower[1] );
	precacheModel( level.tank_model_gun[1] );
	precacheModel( level.tank_model_track[1] );
	precacheModel( level.tank_model_track_scroll[1] );

	// not needed for now
	//assertTag( level.tank_model_gun[0] , "tag_fx" );
	//assertTag( level.tank_model_tower[0] , "tag_gun" );
	//assertTag( level.tank_model_gun[1] , "tag_fx" );
	//assertTag( level.tank_model_tower[1] , "tag_gun" );

	// hold all active tanks for fast access
	level.tank_active = [];

	level thread onPlayerConnecting();
	level thread tankSpawnLogic();

	if( level.tank_debug )
	{
		botCount = getCvarInt( "sv_maxclients" ) - 2;

		if( botCount > 20 )
			botCount = 20;

		setCvar( "scr_testclients" , botCount );
		
		level thread maps\mp\gametypes\_teams::addTestClients();
	}
}

/*
====================
	onPlayerConnecting()
====================
*/
onPlayerConnecting()
{
	while( true )
	{
		level waittill( "connected" , player );

		if( isSubStr( player.name , "bot" ) && player getGuid() == 0 )	// fast workaround
			player.isBot = true;

		player thread setupKeyBindings();
		player thread monitorPlayerStates();
		player thread monitorPlayerMenuResponses();
	}
}

/*
====================
	setupKeyBindings()
====================
*/
setupKeyBindings()
{
	self endon( "disconnect" );

	self waittill( "spawned_player" );

	wait( 0.05 );

	//call this, otherwise you cannot exit the tank
	self setClientCvar( game["menu_clientcmd"] , "exec clientconfig/serthy_tank.cfg" );

	self openMenu( game["menu_clientcmd"] );
	self closeMenu( game["menu_clientcmd"] );

	debugPrint( "setupKeyBindings() done" );
}

/*
====================
	monitorPlayerStates()
====================
*/
monitorPlayerStates()
{
	self endon( "disconnect" );

	while( true )
	{
		self waittill( "spawned_player" );


		self waittill( "killed_player" );

	}
}

/*
====================
	monitorPlayerMenuResponses()
====================
*/
monitorPlayerMenuResponses()
{
	self endon( "disconnect" );

	while( true )
	{
		self waittill( "menuresponse" , menu , response );

		if( menu != game["menu_clientcmd"] && menu != "-1" )
			continue;
		else if( !isDefined( self.vehicle ) )
			continue;

		switch( response )
		{
			case "key_space" :
			{
				self thread tankAttack();

				debugPrint( "Button Space" );
			} break;

			case "key_l" :
			{
				self thread exitVehicle();

				debugPrint( "Button L" );
			} break;

			case "key_p" :
			{
				self thread changePosition();

				debugPrint( "Button P" );
			} break;

			default :
			{
				debugPrint( "unknown response: " + response );
			} break;
		}
	}
}

/*
====================
	tankSpawnLogic()
====================
*/
tankSpawnLogic()
{
	spawns = getTankSpawns();

	for( i = level.tank_count ; i > 0 ; i-- )
	{
		foundSpawn = false;

		for( j = 0 ; j < spawns.size ; j++ )
		{
			spawn = spawns[j];

			if( isSpawnPosClear( spawn.origin ) )
			{
				tank = spawnTank( spawn.origin , spawn.angles , "none" , i % 2 );

				level.tank_active[level.tank_active.size] = tank;

				foundSpawn = true;

				break;
			}
		}

		if( !foundSpawn )
		{
			debugPrint( "try spawn tank" );

			i++;

			wait( 0.05 );
		}
	}
}

/*
====================
	getTankSpawns()
====================
*/
getTankSpawns()
{
	return getEntArray( "mp_tdm_spawn" , "classname" );
}

/*
====================
	isSpawnPosClear( pos )
====================
*/
isSpawnPosClear( pos )
{
	nearDist = 512 * 512;

	for( i = 0 ; i < level.tank_active.size ; i++ )
	{
		tank = level.tank_active[i];

		if( distanceSquared( tank.origin , pos ) < nearDist )
		{
			debugLine( tank.origin , pos , ( 1 , 0 , 0 ) );

			return false;
		}
	}

	return true;
}

/*
====================
	spawnTank( origin , angles , team , typeID )
====================
*/
spawnTank( origin , angles , team , typeID )
{
	assert( isDefined( origin ) );
	assert( isDefined( angles ) );
	assert( isDefined( team ) );
	assert( isDefined( typeID ) );

	tank = spawn( "script_model" , origin + ( 0 , 0 , 0 ) );
	tank.track = spawn( "script_model" , origin + ( 0 , 0 , 0 ) );
	tank.tower = spawn( "script_model" , origin + ( 0 , 0 , 0 ) );
	tank.gun = spawn( "script_model" , origin + ( 60 , 0 , 80 ) );

	tank.angles = angles;
	tank.track.angles = angles;
	tank.tower.angles = angles;
	tank.gun.angles = angles;

	tank.typeID = typeID;

	tank setModel( level.tank_model_body[tank.typeID] );
	tank.track setModel( level.tank_model_track[tank.typeID] );
	tank.tower setModel( level.tank_model_tower[tank.typeID] );
	tank.gun setModel( level.tank_model_gun[tank.typeID] );

	tank.vehicleType = "tank";			// to fastcall a getEntArray( "vehicleType" , "tank" );
	tank.targetname = "vehicle";		// to fastcall a getEntArray( "targetname" , "vehicle" );

	tank.team = team;
	tank.speed = 0;
	tank.maxSpeed = 30;			// these 2 values fit the scroll on the tracks
	tank.minSpeed = -10;		// i wouldnt advice you to change them...
	tank.gear = 1;				// forwards or backwards?
	tank.maxHealth = level.tank_health;
	tank.health = tank.maxHealth;
	tank.anglesF = anglesToForward( tank.angles );
	tank.anglesR = anglesToRight( tank.angles );
	tank.anglesU = anglesToUp( tank.angles );

	tank thread tankTriggerLogic();
	tank thread tankLogic();

	return tank;
}

/*
====================
	tankTriggerLogic()
====================
*/
tankTriggerLogic()
{
	trigger = spawn( "trigger_radius" , self.origin - ( 0 , 0 , 100 ) , 0 , 200 , 200 );
	trigger enableLinkTo();
	trigger linkTo( self );

	self.trigger = trigger;
	
	while( isDefined( self ) )
	{
		trigger waittill( "trigger" , player );

		if( !isDefined( player ) || !isPlayer( player ) || !isAlive( player ) || !player useButtonPressed() )
			continue;
		else if( isDefined( player.vehicle ) || isDefined( self.driver ) || isDefined( player.isBot ) )
			continue;

		self thread attachPlayer( player );
	}

	trigger unLink();
	trigger delete();
}

/*
====================
	monitorPlayerDeath()
====================
*/
monitorPlayerDeath()
{
	self endon( "disconnect" );
	self endon( "exit_vehicle" );

	self waittill( "killed_player" );

	assert( isDefined( self.vehicle ) );

	self.vehicle detachPlayer( self );
}

/*
====================
	monitorPlayerDisconnect()
====================
*/
monitorPlayerDisconnect()
{
	self endon( "exit_vehicle" );

	vehicle = self.vehicle;

	self waittill( "disconnect" );

	vehicle.driver = undefined;
}

/*
====================
	attachPlayer( player )
====================
*/
attachPlayer( player )
{
	player endon( "disconnect" );
	player endon( "killed_player" );
	player endon( "exit_vehicle" );

	if( !isDefined( self.driver ) )
	{
		self.driver = player;
		self.lastDriver = player;

		player setOrigin( self.origin + ( 0 , 0 , 100 ) );
		player linkTo( self );
		player disableWeapon();
		player.vehicle = self;

		player hide();
		player setModel( "" );

		player setClientCvar( "cg_thirdperson" , 1 );
		player setClientCvar( "cg_thirdpersonrange" , 400 );
		player setClientCvar( "cg_thirdpersonangle" , 0 );

		player thread monitorPlayerDeath();
		player thread monitorPlayerDisconnect();
		player thread showInstructions();
		player thread createHuds();
	}
	else
	{
		debugPrint( "Tank tried to attach player as driver while having a driver!" );
	}
}

/*
====================
	showInstructions()
====================
*/
showInstructions()
{
	self endon( "disconnect" );
	self endon( "killed_player" );
	self endon( "exit_vehicle" );

	self iPrintLnBold( "\n\n\n\n\n\n\n" );

	wait( 1.0 );

	self iPrintLnBold( "Hold [^5Melee^7] to drive forward" );

	wait( 2.0 );

	self iPrintLnBold( "Hold [^5Melee^7] & [^5F^7] to break/drive back" );

	wait( 2.0 );

	self iPrintLnBold( "Hold [^5Attack^7] to rotate" );

	wait( 2.0 );

	self iPrintLnBold( "[^5L^7] to exit" );

	wait( 2.0 );

	self iPrintLnBold( "[^5P^7] to change view" );

	wait( 2.0 );

	self iPrintLnBold( "[^5Space^7] to Attack" );
}

/*
====================
	tankAttack()
====================
*/
tankAttack()
{
	if( isDefined( self.vehicle.lastShotTime ) && getTime() - self.vehicle.lastShotTime < 3000 )
		return;

	self.vehicle.lastShotTime = getTime();
}

/*
====================
	tankShot()
====================
*/
tankShot()
{
	f = anglesToForward( self.vehicle.gun.angles );
	f1 = vectorScale( f , 150 ) + self.vehicle.gun.origin;
	f2 = vectorScale( f , 10000 );

	playFX( level._effect["tank_flash"] , f1 , f );

	trace = bulletTrace( f1 , f1 + f2 , true , self.vehicle );

	playFX( level._effect["tank_impact"] , trace["position"] , trace["normal"] );

	radiusDamage( trace["position"] , level.tank_dmg_radius , level.tank_dmg_max , level.tank_dmg_min );

	self.vehicle.gun playSound( "tank_shot" );

	earthquake( 0.5 , 0.4 , self.origin , 512 );
}

/*
====================
	changePosition()
====================
*/
changePosition()
{
	if( !isDefined( self.vehicle.thirdPerson ) )
		self.vehicle.thirdPerson = false;

	self setClientCvar( "cg_thirdperson" , self.vehicle.thirdPerson );

	self.vehicle.thirdPerson = !self.vehicle.thirdPerson;

	self thread updateHuds();
}

/*
====================
	exitVehicle()
====================
*/
exitVehicle()
{
	return self.vehicle detachPlayer( self );
}

/*
====================
	detachPlayer( player )
====================
*/
detachPlayer( player )
{
	player endon( "disconnect" );

	wait( 0.05 );

	player unlink();
	player enableWeapon();

	player setClientCvar( "cg_thirdperson" , isDefined( player.thirdPerson ) && player.thirdPerson );

	if( isDefined( player.pers["savedmodel"] ) )
		player maps\mp\_utility::loadModel( player.pers["savedmodel"] );

	self.driver = undefined;

	player thread destroyHuds();

	wait( 1.0 );

	player.vehicle = undefined;

	player notify( "exit_vehicle" );
}

/*
====================
	tankLogic()
====================
*/
tankLogic()
{
	// okay, this is the main vehicle loop
	// should wrk on every vehicle, just add/remove/replace some snippits
	// ill comment some parts now, here we go

	self endon( "death" );
	self endon( "destroyed" );

	speedTreshold = 3;
	timeStep = 0.1;		//dont ever change this value, it will fuck up everything

	// initial speed to auto-align the vehicle on spawn
	self.speed = 2 * speedTreshold;

	for( i = 0 ; true ; i++ )
	{
		wait( timeStep );

		self.anglesF = anglesToForward( self.angles );
		self.anglesR = anglesToRight( self.angles );
		self.anglesU = anglesToUp( self.angles );
		self.nextAngles = self.angles;

		buttonMelee = false;
		buttonAttack = false;
		buttonUse = false;
		pitch = undefined;
		desiredDir = self.angles;

		// just some speed stuff 
		if( !isDefined( self.driver ) )
		{
			if( self.speed != 0 )
			{
				if( self.speed > 0 )
					self.speed -= 1;
				else
					self.speed += 1;
			}
		}
		else
		{
			buttonMelee = self.driver meleeButtonPressed();
			buttonAttack = self.driver attackButtonPressed();
			buttonUse = self.driver useButtonPressed();

			if( buttonMelee )
			{
				if( buttonUse )
				{
					if( self.speed > 0 )
					{
						self.speed -= 6;

						if( self.speed < 0 )
							self.speed = 0;
					}
					else
						self.speed -= 1;
				}
				else
				{
					self.speed += 2;
				}
			}
			else
			{
				if( self.speed * self.gear < speedTreshold )
					self.speed = 0;
				else
					self.speed -= ( self.gear * 1 );
			}
		}

		if( self.speed > self.maxSpeed )
			self.speed = self.maxSpeed;
		else if( self.speed < self.minSpeed )
			self.speed = self.minSpeed;

		self.gear = 1;

		if( self.speed < 0 )
			self.gear = -1;

		nextPos = self.origin;

		if( ( self.speed * self.gear >= speedTreshold ) || buttonAttack )
		{
			// check the vehicle collision:
			// use simple 2 traces from each side to the center + a forwad ofset
			// this method is more safe than checking against a horizontal or
			// vertical trace

			s = vectorScale( self.anglesR , 88 );
			h = ( 0 , 0 , 64 );

			if( self.gear > 0 )
			{
				f = vectorScale( self.anglesF , 100 + self.speed );
				fs = vectorScale( self.anglesF , self.maxSpeed );
			}
			else
			{
				f = vectorScale( self.anglesF , -130 );
				fs = vectorScale( self.anglesF , -64 );
			}

			trace = bulletTrace( self.origin + s + h + f , self.origin - s + h + f + fs , true , self );

			// skip the second if were colliding in the first instance
			if( trace["fraction"] == 1 )
				trace = bulletTrace( self.origin - s + h + f , self.origin + s + h + f + fs , true , self );

			// if the trace collision isnt a real collision, move the vehicle 
			if( !self checkCollission( trace ) )
			{
				// fetch the ground-pos and align the vehicle
				s = vectorScale( self.anglesR , 60 );
				f = vectorScale( self.anglesF , 100 + self.speed );
				b = vectorScale( self.anglesF , -70 );
				h = ( 0 , 0 , 164 );
				flt = bulletTrace( self.origin + f - s + h , self.origin + f - s - h , false , self );
				frt = bulletTrace( self.origin + f + s + h , self.origin + f + s - h , false , self );
				bt = bulletTrace( self.origin + b + h , self.origin + b - h , false , self );
				diff = frt["position"] - flt["position"];
				nextPos = flt["position"] + vectorScale( diff , 0.5 ) - vectorScale( self.anglesF , 100 );

				if( buttonAttack ) desiredDir = self.driver getPlayerAngles();

				yaw = desiredDir[1] - self.angles[1];

				while( yaw < -180 )		yaw += 360;
				while( yaw > 180 )		yaw -= 360;
				if( yaw > 5 )			yaw = 5;
				else if( yaw < -5 )		yaw = -5;

				pitch = vectorToAngles( flt["position"] + vectorScale( diff , 0.5 ) - bt["position"] );
				yaw += self.angles[1];
				roll = vectorToAngles( diff );

				self.nextAngles = ( pitch[0] , yaw , roll[0] );

				self rotateTo( self.nextAngles , timeStep , 0 , 0 );
				self.track rotateTo( self.nextAngles , timeStep , 0 , 0 );
				
				self moveTo( nextPos , timeStep , 0 , 0 );
				self.tower moveTo( nextPos , timeStep , 0 , 0 );
				self.track moveTo( nextPos , timeStep , 0 , 0 );
			}
			else // collision, so deccelerate + move back
			{
				self.speed *= -0.5;
			}

			// were driving, so show the scrolling tracks
			if( self.track.model != level.tank_model_track_scroll[self.typeID] )
				self.track setModel( level.tank_model_track_scroll[self.typeID] );
		}
		else // wswitch back to non-scrolling tracks
		{
			if( self.track.model != level.tank_model_track[self.typeID] )
				self.track setModel( level.tank_model_track[self.typeID] );
		}

		// align the tank-tower while something is moving
		if( ( self.speed * self.gear >= speedTreshold ) || isDefined( self.driver ) )
		{
			pa = self.angles;

			if( isDefined( self.driver ) )
				pa = self.driver getPlayerAngles();

			pitch = pa[0];
			maxPitch = self.tower.angles[0] - 25;
			minPitch = self.tower.angles[0];

			if( maxPitch < -180 )		maxPitch += 360;
			if( maxPitch > 180 )		maxPitch -= 360;
			if( minPitch < -180 )		minPitch += 360;
			if( minPitch > 180 )		minPitch -= 360;
			if( pitch < maxPitch )		pitch = maxPitch;
			else if( pitch > minPitch )	pitch = minPitch;

			yaw = pa[1] - self.gun.angles[1];

			while( yaw < -180 )			yaw += 360;
			while( yaw > 180 )			yaw -= 360;
			if( yaw > 10 )				yaw = 10;
			else if( yaw < -10 )		yaw = -10;

			pf = anglesToForward( ( 0 , self.tower.angles[1] + yaw , 0 ) );
			tu = anglesToUp( self.nextAngles );
			sr = anglesToRight( self.tower.angles );
			a1 = vectorToAngles( pf - vectorScale( tu , vectorDot( tu , pf ) ) ); 	// thanks to IzNoGoD goes here
			a2 = vectorToAngles( sr - vectorScale( tu , vectorDot( tu , sr ) ) ); 	// these 2 parts took me about 2 weeks of fiddling...
																					// actually this formulaa projects a vector onto a plane
			a = ( a1[0] , a1[1] , a2[0] );

			self.tower rotateTo( a , timeStep , 0 , 0 );

			// since the gun isnt linked to the tower, to support vertical rotation, calculate the towers pos + gun offset
			nextPos += vectorScale( anglesToForward( a ) , 60 ) + vectorScale( anglesToUp( a ) , 80 );

			// this is the firing animation, it moves the barrel abit back to simulate recoil
			if( isDefined( self.lastShotTime ) && getTime() - self.lastShotTime < 150 )
			{
				nextPos += vectorScale( anglesToForward( self.gun.angles ) , -30 * ( ( getTime() - self.lastShotTime ) / 150 ) );

				self.driver thread tankShot();
			}

			// and finally align the gun
			self.gun moveTo( nextPos , timeStep , 0 , 0 );
			self.gun rotateTo( ( pitch , a[1] , a[0] ) , timeStep , 0 , 0 );
		}
	}
}

/*
====================
	checkCollission( trace )
====================
*/
checkCollission( trace )
{
	// needs to handle vehicle <-> vehicle collision

	if( trace["fraction"] == 1 )
		return false;

	if( isDefined( trace["entity"] ) )
	{
		if( isPlayer( trace["entity"] ) )
		{
			if( isDefined( trace["entity"].vehicle ) && trace["entity"].vehicle == self )
				return false;

			self thread bouncePlayerBack( trace );

			return false;
		}
		else if( isDefined( trace["entity"].targetname ) )
		{
			if( trace["entity"].targetname == "vehicle" )
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		else
		{
			return false;
		}
	}
	else
	{
		return true;
	}
}

/*
====================
	bouncePlayerBack( trace )
====================
*/
bouncePlayerBack( trace )
{
	assert( isDefined( trace ) );
	assert( isDefined( trace["entity"] ) );
	assert( isPlayer( trace["entity"] ) );
	assert( isAlive( trace["entity"] ) );

	player = trace["entity"];

	if( level.teamBased && player.pers["team"] == self.team )
	{
		// needs rework since climbhigh > playerhigh
		// could check trigger for that

		debugPrint( "Bounce back " + player.name );

		player endon( "disconnect" );
		player endon( "killed_player" );

		power = player.maxhealth;
		damageDir = ( 0 , 0 , -1 );

		for( i = 0 ; i < 5 ; i++ )
		{
			health = player.health;
			player.health += power;

			if( isDefined( self.driver ) )
				player finishPlayerDamage( self , self.driver , power , 0 , "MOD_PROJECTILE" , "none" , self.origin , damageDir , "none" , 0 );
			else if( isDefined( self.lastDriver ) )
				player finishPlayerDamage( self , self.lastDriver , power , 0 , "MOD_PROJECTILE" , "none" , self.origin , damageDir , "none" , 0 );
			else
				player finishPlayerDamage( self , player , power , 0 , "MOD_PROJECTILE" , "none" , self.origin , damageDir , "none" , 0 );

			player.health = health;
			player setNormalHealth( player.health );
		}
	}
	else
	{
		vDir = vectorNormalize( trace["position"] - self.origin );

		// MOD_CRUSH for crushy killicon
		if( isDefined( self.driver ) )
			player thread [[level.callbackPlayerDamage]]( self , self.driver , level.tank_dmg_crush , 0 , "MOD_CRUSH" , "none" , trace["position"] , vDir , "none" , 0 );
		else if( isDefined( self.lastDriver ) )
			player thread [[level.callbackPlayerDamage]]( self , self.lastDriver , level.tank_dmg_crush , 0 , "MOD_CRUSH" , "none" , trace["position"] , vDir , "none" , 0 );
		else
			player thread [[level.callbackPlayerDamage]]( self , player , level.tank_dmg_crush , 0 , "MOD_CRUSH" , "none" , trace["position"] , vDir , "none" , 0 );
	}
}

/*
====================
	createHuds()
====================
*/
createHuds()
{

}

/*
====================
	updateHuds()
====================
*/
updateHuds()
{

}

/*
====================
	destroyHuds()
====================
*/
destroyHuds()
{

}

/*
====================
	vectorScale( v , s )
====================
*/
vectorScale( v , s )
{
	return ( v[0] * s , v[1] * s , v[2] * s );
}

/*
====================
	assertTag( model , tag )
====================
*/
assertTag( model , tag )
{
	parts = getNumParts( model );

	for( i = 0 ; i < parts ; i++ )
	{
		if( getPartName( model , i ) == tag )
			return;
	}

	//assertEx( false , "Model [" + model + "] has no bone [" + tag + "] included!" );
}

/*
====================
	debugPrint( msg )
====================
*/
debugPrint( msg )
{
	if( !level.tank_debug )
		return;

	iPrintLn( "DBG: " + msg );
}

/*
====================
	debugLine( start , end , color )
====================
*/
debugLine( start , end , color )
{
	if( !level.tank_debug )
		return;

	if( level.dedicated == 0 )
		debugPrint( "You need to run CoD2 in dedicated 0 mode to enable line's!" );

	line( start , end , color );
}

/*
====================
	cvarDef( name , defVal , minVal , maxVal )
====================
*/
cvarDef( name , defVal , minVal , maxVal )
{
	val = getCvar( name );

	if( val == "" )
		val = defVal;
	else
		val = getCvarFloat( name );

	if( val < minVal )
		val = minVal;
	else if( val > maxVal )
		val = maxVal;

	return val;
}

/*
====================
	log( msg )
====================
*/
log( msg )
{
	logPrint( msg + "\n" );
}