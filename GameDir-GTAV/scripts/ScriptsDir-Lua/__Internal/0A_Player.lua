local setmetatable = setmetatable
local PlayerId, PlayerPedId, GetEntityCoords, IsPedInAnyVehicle, GetVehiclePedIsIn, GetPedInVehicleSeat, NetworkGetNetworkIdFromEntity, GetEntityModel, GetDisplayNameFromVehicleModel, IsThisModelABicycle, IsThisModelABike, IsThisModelABoat, IsThisModelACar, IsThisModelAHeli, IsThisModelAJetski, IsThisModelAPlane, IsThisModelAQuadbike, IsThisModelATrain, IsThisModelAnAmphibiousCar, IsThisModelAnAmphibiousQuadbike
	= PlayerId, PlayerPedId, GetEntityCoords, IsPedInAnyVehicle, GetVehiclePedIsIn, GetPedInVehicleSeat, NetworkGetNetworkIdFromEntity, GetEntityModel, GetDisplayNameFromVehicleModel, IsThisModelABicycle, IsThisModelABike, IsThisModelABoat, IsThisModelACar, IsThisModelAHeli, IsThisModelAJetski, IsThisModelAPlane, IsThisModelAQuadbike, IsThisModelATrain, IsThisModelAnAmphibiousCar, IsThisModelAnAmphibiousQuadbike
return setmetatable(
	{
		InfoKeyName	=	"Player",
		Id			=	0,
		Ped			=	0,
		Handle		=	0,
		Coords		=	0,
		Vehicle		=	{
							IsIn	=	0,
							IsOp	=	0,
							Id		=	0,
							Handle	=	0,
							NetId	=	0,
							Model	=	0,
							Name	=	0,
							Type	=	setmetatable({},{__index=function() return false end}),
						}
	},
	{
		__call	=	function(Self)
						Self.Id				= PlayerId()
						local Ped			= PlayerPedId() Self.Ped,Self.Handle=Ped,Ped
						Self.Coords			= GetEntityCoords(Ped, false)
						local IsIn			= IsPedInAnyVehicle(Ped, false) Self.Vehicle.IsIn = IsIn
						if IsIn then
							local Vehicle	= Self.Vehicle
							local Veh		= GetVehiclePedIsIn(Ped, false)
							Vehicle.IsOp	= Ped == GetPedInVehicleSeat(Veh, -1)
							
							if Veh == Vehicle.Id then return end
							
							Vehicle.Id,Vehicle.Handle=Veh,Veh
							Vehicle.NetId	= NetworkGetNetworkIdFromEntity(Veh)
							local VehModel	= GetEntityModel(Veh) Vehicle.Model = VehModel
							Vehicle.Name	= GetDisplayNameFromVehicleModel(VehModel)
							
							local Vehicle_Type = Vehicle.Type
							Vehicle_Type.Bicycle			= IsThisModelABicycle(VehModel)
							Vehicle_Type.Bike				= IsThisModelABike(VehModel)
							Vehicle_Type.Boat				= IsThisModelABoat(VehModel)
							Vehicle_Type.Car				= IsThisModelACar(VehModel)
							Vehicle_Type.Heli				= IsThisModelAHeli(VehModel)
							--Vehicle_Type.Jetski				= IsThisModelAJetski(VehModel)
							Vehicle_Type.Plane				= IsThisModelAPlane(VehModel)
							Vehicle_Type.Quadbike			= IsThisModelAQuadbike(VehModel)
							Vehicle_Type.Train				= IsThisModelATrain(VehModel)
							--Vehicle_Type.AmphibiousCar		= IsThisModelAnAmphibiousCar(VehModel)
							--Vehicle_Type.AmphibiousQuadbike	= IsThisModelAnAmphibiousQuadbike(VehModel)
						end
					end
	}
)
