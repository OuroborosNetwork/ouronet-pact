# Ouronet IGNIS pricing — pending feedback (recovered from a wedged conversation)

> Recovered 2026-09-05 00:16 from conversation ad269259 (grew to 164 MB and stalled on resume).
> The worksheet itself is safe and committed (last: c8b258f — ops sorted alphabetically, coloured by column).
> Below is the owner's recent pricing feedback that the stalled turn never finished processing. Continue from here.
> Full original conversation archived at: .claude/workspace/OuroborosNetwork~2f~_onchain~2f~Ouronet@main/9b41003b-...jsonl

## Owner's recent pricing feedback (verbatim, oldest→newest)

- of course, all this this new structure and logic, has to come in the documentation part, which is part of the later chapter, once the final shape of the code is done.

- so let me understand better what you are suggesting, a single IG|U price of 10 units, from which everything else is derived via multipliers ? yes we can go with that. do not that we already have some saved values in the the price table, but that shouldnt bother us.

- in this case, we woudnlt even need to make it as a write ina table, but add it as a tru constant, and derive all other prices from it.

- so this would make 10 ignis the lowest price for the cheapest cost, right ?

- 2) issuae versus usage spread is 20x, thats about right (wouldnt that mean 2000 vs 100 ? :))) )

- 3)yes, i gues thats true

- 4)i would want it, but it has to come as a suggestion from you, i wouldnt know what to want. i need a suggestion from you that is justified logically, why did you add it like so and not in a different manner.

- also i need you to know something. The idea of the Ouronet was to create token trasnaction simples, 1 cent per transaction. that was the original idea, which obviously didnt work, i tried to work around it, which creted the transfer classes. as you can see transfers can be depending on their class, 1 2 3 ignis cost,

- im afraid if we make the smallest price 10 Ignis it might be too much.

- however when looking at bitcoin and ethereum trasnaction, even 10 cents for moving something might be extremly cheap. but im afraid we need smaller granularity. what do you think about this (we are still arguing and settleing on the design)

- this step with ignis repricing become thus one huge stage on its own which needs to be properly planned, substaged etc, we can do all of this in one hop.

- still i dont want gas fees to be too small, they go to custodians, and and they gotta earn something.

- still i think 1 ignis per transfer might be a little to small. while 10 might be a little to much.

- the transfer itself then might be cheaper or more expensive depnding on whats beingt ransfered (for example elite auryn updates elite accoutns, so thatsa a huge extra cost)

- so what do you suggest we do ? go with 5 as the smallest unit of pricing, or maybe stick with 10,, the thing is, why do we have then the 1 ignis, if we use 5 and 10. we gotta make usage somehow of the samllest unit as well. 

- so we could use 1 as the atomic gas unit, but use multipliers for different fees. or maybe even stick to 10, but be able to go down up to 1, if needed. 

- what do you suggest we use as price for a single token transfer, i feel 1 is to little. look at ethereum movement fees. nobody is paying 1 cent to move tokens, they are costing dollars.

- so maybe 10 ignis per trasnfer isnt that faar fetched scaling upwards for more complex transfers, for example a bulk transfer, instead of cosing 10 times 3 (if we tranfer to 3 targets, the mere fact that you use this functionality is a fixed 100 ignis price)

- just an example. we need a scaling cost for something that scales,, and a fixed one timer price "pauschal" for using a special functionality.

- so for tranfers maybe 5 flat + 5 for it being class 1. or soemthing like that. what do you think ? i wnat to go something along this route

- the thing is 1 IGNIS ALWAYS 1 cent(dollar cent, or euro cent), that is always on cosntant value (ignis is basically a sort fo stable coin)

- class 3 is elite auryn transfer, just so you know.

- or maybe, just maybe derive the cost of a given transaction, by its complexity. a single client function that simply write a boolean in a table, should cost 1 ignis per write. a transfer function, even ifi ts a trasnfer function, is faar more complex than that, and should rightfully cost a lot more, split per components, making it 5 or 10 or 50 (gut feeling) we are falling in the previous trap i fflagged we want to come out of, right ?

- so if the transfer function is a complex transaction, it should cost more, not be 1 ignis, or 5 ignis, simple becuase its a transfer, dont you think ?

- yes, we make Ignis the honest compute meter. and stoa the deterance meter.

- so this mean we simply each function into a number of its components

- carefull tunning those, would get us the ignis price.

- However i suggest, IG|TX instead of 1, we multiple variants of those. for example and adding liquidty transaction should have a faar bigger charge in ignis, since here i added 1000 ignis or something like that for simply adding liqudity. or removing it, to detter multiple smaller additions. the thing is we cant deter in this case with Stoa, or perhaps we could but using faar smaller values. the thing is with deterring in stoa its complicated, because, stoa is variable in price, once we get its price, we need to make it variable, not fixed.

- since ignis is fixed, thats why i used ignis for adding and removing liqudity.

- so i think we need to also add a Detter price in ginis per function. which is as big or as littel depedning on how much we want to detter that function. basicaly using a detter multiplier. the detter multiplier is applied to the IG|TX to get the final tx price. im not sure how the hell we could do this for every transactions, maybe write it in its doc. tag, or it should be added in the doc tag of the Talos orchestrator, since  thats the final shape the client is calling...

- Detter-factor 1x measn the Tx has a cost of 1x1=1. a detter of 25, means the tx cost is 25 ignis.

- i dont say we take out the stoa dettering plan, but that should be reserved for those special cases where further deterance is needed. some function might have a high deterance factor but no extra stoa cost.

- Default deters ce is 1 meaning no extra cost. I want you to publish a document suggesting deters ce costs for each function we are processing, I will revise and green light. Tell me how do you sugest we save severance factor. and give me the final cost in ignis of the building blocks for the ibis computation

- The thing is a writes and inserts new whole field. Update can update a single field in the row. This means bigger fields for update and insert are more costly. Shouldn't we target a per field cost for these? To be more exact? Which would be 1 if is per field actually written per update, and 1 if is per field size in write and insert. But even that isn't correct ,since writing a single string or a huge o next costs differently. So how the fuck we tackle this?

- Module hop shouldn't be taxed when the hop is coming from talos, but the other actual hops. Because talos hops always since it's the orchestrator, correct?

- I think we should store deterence constants in the finish module, not in talos?

- Wait you want to apply the deterence factor to the whole computed sum? I thought we only applied it to the tx unit which was 1 ignis....

- Suggest deter factor for every other ope as well some settings changes should be slightly expensive role setups changes of properties etc. fee changes on exchange etc

-  We need smaller deter factors for management functions and no deter or very big detr for activity actions.

- Issuance must also have deter factors. As you already see from current implementation

- Account deploys no finish cost whatsoever, for ouronet accounts only stoa prices, as before token issuance was sitting at 20 30 40 50 stoa, and also some price in it is (deterence).

- Collect in ignite is the exact function that collects all it is from a transaction must have any cost.

- Compress and sublimate makes or breaks it is, that why also no it is cost. Firestarter also no it is cost .ouronet account creation are 2 standard 2 admin variants I don't know about 7 variants....

- (Please DISREGARD my discarded message(s) above — do not act on it: “Collect in ignite is the exact function that collects all it is from a”. Act only on what follows.)

- C_Collect in ignis is the function that collects all ignis cost of a given function. Itself must have no cost 

- Compress and sublimate are ignis make and break functions, they must be glassless. Firestarter as well 

- Ouronet account deploys are 2 made by users 2 made by admin ,the ones made by users carry stoa costs, the ones by admin are free. So I don't know where you got that there are 7 of them. I will revise deter costs when I get home

- No those deploy accounts for dptf dpof dpsf and dpnf must also be free, when someone sends a token from a to b, and b hasn't got an account is created on the spot, and must be taxed in ignis. So this is also free. However, if anyone is triggering it on purpose, then yes it has to have a cost in ignis

- I'm not familiar with A_DeployBridgeSmartAccount where is it coming from?

- I will revise the list once I'm home on computer. Caduceus module is work in progress, we are not deploying it yet. First Arweave needs integration on ouronet UI, then we're working on caduceus and Aletheia.

- can you update the md file with the deter values, 

- | op | role | ins/wr | upd | R | S | X | components | cur GAS\| | deter | final | rationale |

- for each category a different colour, and deter in x-es like 25x 50x 100x 1000x to better observ whats what ?

- i meant each colour of the 

- | op | role | ins/wr | upd | R | S | X | components | cur GAS\| | deter | final | rationale |

- meaning each number represing that specific part, should be coloured differently, that why i could observe at a glance per op, what the cost for specific parts are

- also, for citizen modules, only the DPAD modules are to be included in this, they have their owen talos agregator. the remaining should be out of scope. and would have to have their price included into their components. pure citizen modules.

- demipad citizen modules, are "higher" citizen modules, with hteir own talos, and those should behave similar to sovereign, in this thing.

- also all the deffer x prices make them one singular coloure noe theuir mixed, i dont understant shit, what i wanted was that eacp part op for example, a singular colour, role a singular colour ins/wr one singular colour,  deter, one singular colour, and coloured of the text, not add a square with colour, cant you colour md files ?

- okay, for each module, the ops, i want them placed in alphabetic order (im still inspecting them). do this, then ill tell you waht to modify

- all A_ functions must be exempted, they are admin functions, run byu the Ouronet Admin, to set up sovereing settings, and must be ignis and stoa free.

- C_TransferDalosFuel also exempt, its basically a coin.transfer execution

- Issuance must be more than 50x. Issuance must have a strong price in Ignis, issuaing new assets,

- Isssuance of new Assets, 

- true fungible 10$, Ortofungible 10$, semifungible 20$, nonfungible 25$ (one ignis is 1 cent)

- when it comes to sft and nft the function is C_IssueDigitalCollection with son:bool splitter spliting between sft and nft

- also for ortofungible wiping must be nonce depndendt, the more nonces are involved the more expensive it gets, 5 ignis per nonce wiped.

- this scaled operation involving multiple nonces, and scales for wiping that doesnt fit into  gas limit (when you need to create paralele transactions). Apropos, i think we need to add paralelisation for wiping functions (like we have paralelisation in the VCT module of the aquisition pools). in case a single wipe doesnt fit in gas limit. (this is something we missed, write it down, we need to do it i think before we implement the ignis cost rehaul)

- multitrasnfers of true fungibles must scale with the "multi" part, more tokens more receivers, so their price is i think variable.

- andi  tkae it their componenets, that you listed, depends on how big the list is upon which they operate, dont you think ?

- create frozen link hibernate link reservation link sleeping liink vesting link, issue new assets (ortofungibles), and that should tie into their issuance cost.

- C_SmarSwap also depends on the number of hops being execute, and how many special targets need trnasfering towards, these are variable parts, and would each incurr their composing price, i take it.

- issuing an autostake pair is 40$ in ignis, and issuing a swap pair 50$ in ignis.

- there are add liqudity functions i noticed you add them as part of the MTX-SWP, but those are the ones wcreated with multistep. normlay there are single tx variants sitting in the talos module, as part of the SWP module. so we need to differentiate between the single tx and defpact variatns in the list.

- same for collectible trnasfer, that is dependend on the number of nonces moved. and apart to that the ignis royalty also adds up, (being sent to the collection creator).

- C_MakeFragments and C_MergeFraments are USAGE, and the C_EnableNonceFragmentation is the "ISSUE" function, that should have the 100x detterence multiplier 1$ in ignis per nonce you wish to define as fragmented.

- C_IssueShareholderCollection 100$ in Ignis.

- IssueAnchors half price of issuing their respective asset type.

- C_RevokeAnchor 100x C_RevokeBoostClass 500x

- C_CombineTripletScoreModel = 100x

- C_AddScore 200x

- C_DisablePoolStake and C_EnablePoolStake 50x

- C_RevokeScore from 03_AQP pact 250x

- C_SetCommonDenominator, C_SetMosaic, C_SetQualitySplit, C_SetSplitMode 100x

- C_ToggleRewardLink and C_ToggleScoreEntityLink 50x

- CC_UnstaleMyScores 100x

- But rememebr functions doing heavy lifting like heavy and expensive writes should be counted depending o nthe heaviness of their heavy function.

- also when i comes to DSA module, i think you incorectly taged some of its client function with the A_ prefix

- Creation of a delegation vault is still a normal client function, not something the ouronet admin has to do. As such all the A_ functions in the DSA module, i think they are rather C_ functions, not A_ functions. Or have i got something wrong ?

- Define Delegation Vault should cost cost 50$ in ignis. then the function to create an Agency should be 20$ in Ignis. So someone makes the Delegation vault , and then users creating agencies must pay 20$ in ignis. (is that the C_Admit Agency function ?)

- this is my price feedback

