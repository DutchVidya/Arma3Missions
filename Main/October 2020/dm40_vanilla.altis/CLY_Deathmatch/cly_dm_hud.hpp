	class CLY_hud
   	{
		idd = -1;
		movingEnable = 0;
	  	fadein = 0;
		duration = 9999999;
	  	fadeout = 0;
		name = "CLY_hud";
		onLoad = "uiNamespace setVariable ['CLY_hud', _this select 0]";
		controlsBackground[] = {};
		objects[] = {};
		class controls
		{
			class hud1
			{
				type = 0;
				idc = 23501;
				style = 1;
				x = -2;
				y = -2;
				w = 1;
				h = 0.025;
				sizeEx = 0.025;
				size = 1;
				font = "EtelkaMonospacePro";
				colorBackground[] = {0, 0, 0, 0};
				colorText[] = {0.6, 0.6, 0.6, 1};
				shadow = true;
				text = "";
			};
			class hud2 : hud1
			{
				idc = 23502;
			};
		};   
 	};