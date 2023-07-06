<?php
if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die();
}

include_once("dbconnect.php");

$itemid = $_POST['itemid'];
$item_name = $_POST['itemname'];
$item_desc = addslashes($_POST['itemdesc']);
$item_price = $_POST['itemprice'];
$item_qty = $_POST['itemqty'];
$item_type = $_POST['type'];


$sqlupdate = "UPDATE `tbl_items` SET `item_name`='$item_name',`item_type`='$item_type',`item_desc`='$item_desc',`item_price`='$item_price',`item_qty`='$item_qty' WHERE `item_id` = '$itemid'";

if ($conn->query($sqlupdate) === TRUE) {
	$response = array('status' => 'success', 'data' => null);
    sendJsonResponse($response);
}else{
	$response = array('status' => 'failed', 'data' => null);
	sendJsonResponse($response);
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}

?>