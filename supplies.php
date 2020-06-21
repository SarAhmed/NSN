

<style type='text/css'>

.thesupplies{
    margin : 20px !important;
    width:100px;
    height:500px;
    background-color:white;
    overflow-y:scroll !important;
    padding: 0 55px !important;
}
.col{
    width : 100% !important;
    margin : 20px !important;
}

.card-content{
    padding : 10px !important;
    height:200px !important;
}

.card-action{
    padding : 10px !important;
    height:200px !important;
}

.offers{
    margin-left:400px !important;
    max-width:350px !important;
    max-height: 600px !important;
    background-color:white;
    overflow-y:scroll !important;
}
h6{
    margin:0 !important;
}


.fillIt{
    width: 100% !important;
}
.sticky {
  position: sticky;
  top: 0;
}
.sticky2 {
  position: sticky;
  bottom: 0;
}
</style>

<!DOCTYPE html>
<html lang="en">
<?php include 'templates/header.php'; ?>

    <h4>Market Place</h4>
    <div class="container thesupplies left" >
        <div class="col" id="suppliesWrapper" style="height:80%;" scrolling="yes">
        
        </div>
    <div class="row sticky2" style="visibility:hidden !important;" id="myForm">
        <div class="col s12" style="text-align:true;">
            <div class="row">
                <div class="input-field col s6" style="width:80% !important;">
                    <input placeholder="Supply Name" id="supply_name" type="text" class="validate">
                </div>
                <div class="input-field col s6" style="width:80% !important;">
                    <input placeholder="Supply Description" id="supply_description" type="text" class="validate">
                </div>
                <div class="input-field col s6" style="width:80% !important;">
                    <input placeholder="Start time" id="supply_start" type="text" class="validate">
                </div>
                <div class="input-field col s6" style="width:80% !important;">
                    <input placeholder="End time" id="supply_end" type="text" class="validate">
                </div>
                <button class="brand btn" id="reqBtn" style="margin-top:20%">Confirm</button>
            </div>
        </div>
  </div>
        <div id="showForm" class="sticky2" style="display: flex;width:100%;background-color:red;flex-direction:column;"><button style="flex-grow=1;">Request something</button></div>  
    </div>
    <div class="container center offers" id="offersContainer">
        <div>
            <h6 id="title" class="sticky"></h6>
            <div class="center collection offersWrapper" id="offersWrapper" scrolling="yes">
            
            </div>
        </div>
        <div class="sending">
            <input type="text" id="offerInt" >
            <button id="buttonOffer"> Make Offer</button>
        </div>
    </div>
<script type="text/javascript" src="supplies.js"></script>
</html>