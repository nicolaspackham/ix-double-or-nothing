local PLUGIN = PLUGIN

PLUGIN.name = "Double or Nothing"
PLUGIN.author = "Code Blue"
PLUGIN.description = "Double or Nothing support for Helix."

ix.lang.AddTable("english", {
	DONcannotAffordPlay = "You cannot afford to play!",
    DONownerExists = "This machine belongs to %s, wait for them to finish there turn!",
    DONpleaseWaitSwitch = "Please wait before switching machines!",
    DONcongratsYouWon = "Congratulations, You just won %s.",
    DONjackpotAnnounce = "%s has just won the %s jackpot from Double or Nothing!",
    DONreachX10forJackpot = "Reach X10 for the Jackpot!",
    DONperGameLabel = "PER GAME",
    DONcurrentUser = "Current User: %s",
    DONdontWorry = "Don't Worry",
    DONthisIsntAGlitch = "This isnt a glitch",
    DONiHaveSomething = "I have something",
    DONtoTellYou = "to tell you",
    DONsomethingImportant = "Something important",
    DONCongratulations = "Congratulations",
    DONYouveJust = "You've just",
    DONwonThe = "won the...",
    DONyourPrize = "YOUR PRIZE",
    DONYouWon = "YOU WON!"
})

PLUGIN.bet = 100

PLUGIN.minJackpot = 10000

PLUGIN.maxJackpot = 40000

PLUGIN.doubleChance = 40

PLUGIN.Volume = 1