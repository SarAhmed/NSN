

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

    <h4>Friend Requests</h4>
    <div class="container thesupplies left" >
        <div class="col" id="suppliesWrapper" style="height:80%;" scrolling="yes">
        
        </div>
        <div id="showForm" class="sticky2" style="display: flex;width:100%;background-color:red;flex-direction:column;"><button style="flex-grow=1;">Request something</button></div>  
    </div>
<script type="text/javascript" src="friendRequests.js"></script>
</html>