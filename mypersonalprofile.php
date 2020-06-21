

<style type='text/css'>
.pageContentWrapper{
    display: flex;
    flex-direction: row;
    width:100%;
    height:100%;

}
.infoWrapper{
    height:140px;
    background-color:blue;
    flex-grow:3;
}
.buttonsWrapper{
    display:flex;

}
button{
    flex-grow:1;
    height:30px;
}
.postWrapper{
    flex-grow :2;

    background-color:red;
    border: black solid 1px;
    height:100%

}
.groupWrapper{
    flex-grow :1;

    background-color:yellow;
    border: black solid 1px;
    height:100%;
}

.thechats{
    margin : 20px !important;
    max-width:350px !important;
    max-height: 600px !important;
    overflow-y:scroll !important;
    padding: 0 55px !important;
}
.col{
    width : 200px !important;
    margin : 20px !important;
}

.card-content{
    padding : 10px !important;
}

.singlechat{
    margin-left:400px !important;
    background-color:white;
    overflow-y:scroll !important;
    width:100px;
    height:500px;
}

.me{
    background-color: green !important;
    float:right;
}

.you{
    color: green !important;
    float:left;
}

.fillIt{
    width: 100% !important;
}
div.sticky {
  position: -webkit-sticky; /* Safari */
  position: sticky;
  top: 0;
}

.bigInfoWrapper{
    display:flex;
    flex-direction:row;
}
.rateWrapper{
    flex-grow:1;
    background-color:green;
}
</style>

<!DOCTYPE html>
<?php 
    include 'templates/header.php';
?>
<html lang="en">
<div class='bigDivWrapper'>
<div class="bigInfoWrapper">
<div class ='infoWrapper' id="infoWrapper" >&nbsp</div>
<div class="rateWrapper" id = "rateWrapper">&nbsp</div>
</div>

<div class='pageContentWrapper'>
<div class = 'postWrapper' id ='postWrapper'>&nbsp</div>
<div class = 'groupWrapper' id="groupWrapper">&nbsp</div>

</div>
</div>
<script type="text/javascript" src="mypersonalprofile.js"></script>
</html>