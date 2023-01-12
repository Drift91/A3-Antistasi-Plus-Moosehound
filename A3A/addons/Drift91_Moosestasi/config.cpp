class CfgPatches
{
	class Drift91_Moosestasi
	{
		units[]=
		{
			"Flag_FIA_F"
		};
		weapons[]={};
		requiredVersion=0.1;
		requiredAddons[]=
		{
			"A3_Data_F"
		};
	};
};

class CfgFactionClasses
{
	class IND_G_F
	{
		icon="\Drift91_Moosestasi\textures\flags\cfgFactionClasses_IND_G_ca.paa";
		flag="\Drift91_Moosestasi\textures\flags\Flag_FIA_CO.paa";
	};
	class BLU_G_F
	{
		icon="\Drift91_Moosestasi\textures\flags\cfgFactionClasses_IND_G_ca.paa";
		flag="\Drift91_Moosestasi\textures\flags\Flag_FIA_CO.paa";
	};
	class OPF_G_F
	{
		icon="\Drift91_Moosestasi\textures\flags\cfgFactionClasses_IND_G_ca.paa";
		flag="\Drift91_Moosestasi\textures\flags\Flag_FIA_CO.paa";
	};
};

class CfgVehicles
{
	
	class FlagCarrier;
	class Flag_FIA_F: FlagCarrier
	{
		class EventHandlers
		{
			init = "(_this select 0) setFlagTexture '\Drift91_Moosestasi\textures\flags\Flag_FIA_CO.paa'";
		};
	};
};