ScriptName dsx_dm_QuestController extends Quest

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Faction Property FactionBusy AutoReadOnly
Faction Property FactionIdle AutoReadOnly

String Property DataKeyActorOverride = 'DSXAC.ActorOverride'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function ActorSet(Actor Who, Package Task, Int Lvl)
{force a specific package on an actor.}

	self.ActorRelease(Who, TRUE)

	;;;;;;;;

	If(Task != None)
		If(Who == Main.Player)
			Game.SetPlayerAIDriven(TRUE)
		Else
			If(Task == Main.PackageFollow)
				Who.AddToFaction(Main.FactionFollow)
			Else
				Who.SetDontMove(TRUE)
				Who.SetRestrained(TRUE)
			EndIf
		EndIf

		Who.RegisterForUpdate(9001)
		StorageUtil.SetFormValue(Who,Main.DataKeyActorOverride,Task)
		ActorUtil.AddPackageOverride(Who,Task,100)
		Main.Util.PrintDebug("BehaviourSet applied new package on " + Who.GetDisplayName())
	Else
		If(Who == Main.Player)
			Game.SetPlayerAIDriven(FALSE)
		Else
			Who.SetHeadTracking(TRUE)
			Who.SetDontMove(FALSE)
			Who.SetRestrained(FALSE)
		EndIf

		Debug.SendAnimationEvent(Who,"IdleForceDefaultState")
		Who.UnregisterForUpdate()
		Main.Util.PrintDebug("BehaviourSet released " + Who.GetDisplayName())
	EndIf

	;;Utility.Wait(0.1)
	Who.EvaluatePackage()

	Return
EndFunction

Function ActorRelease(Actor Who, Bool FullRelease=TRUE)

	Package Task = StorageUtil.GetFormValue(Who, self.DataKeyActorOverride) As Package

	If(Task == None)
		Return
	EndIf

	If(FullRelease)
		Who.RemoveFromFaction(self.FactionFollow)
		Who.RemoveFromFaction(self.FactionIdle)
	EndIf

	ActorUtil.RemovePackageOverride(Who, Task)
	StorageUtil.UnsetFormValue(Who, self.DataKeyActorOverride)

	Who.EvaluatePackage()
	Return
EndFunction

