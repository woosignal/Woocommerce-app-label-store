<?php

/**
 * The plugin bootstrap file
 *
 * This file is read by WordPress to generate the plugin information in the plugin
 * admin area. This file also includes all of the dependencies used by the plugin,
 * registers the activation and deactivation functions, and defines a function
 * that starts the plugin.
 *
 * @link              https://woosignal.com
 * @since             1.2.0
 * @package           LabelWoocommerce
 *
 * @wordpress-plugin
 * Plugin Name:       Label WooCommerce
 * Plugin URI:        https://woosignal.com
 * Description:       Label WooCommerce links your WooCommerce store to your mobile app, you need to ensure that you have Label installed on your server before installing. Feature: Allows you to login/signup in the app
 * Version:           1.2.0
 * Author:            Anthony Gordon <support@woosignal.com>
 * Author URI:        https://woosignal.com
 * License:           GPL-2.0+
 * License URI:       http://www.gnu.org/licenses/gpl-2.0.txt
 * Text Domain:       https://woosignal.com
 * Domain Path:       /languages
 */

// If this file is called directly, abort.
if (!defined('WPINC')) { die; }
if (!defined('ABSPATH')) exit; // Exit if accessed directly

define('PLUGIN_NAME_VERSION', '1.0.0');

function label_insert_into_db() {    

require_once( ABSPATH . 'wp-admin/includes/upgrade.php' );
}

function label_activate_login() {
    require_once plugin_dir_path( __FILE__ ) . 'includes/class-login-activator.php';
    Login_Activator::activate();

    label_insert_into_db();
}


/**
 * label_sign_up
 *
 * Sign up a new user into the store.
 *
 * @param Array - Containing 'id', 'first_name', 'last_name', 'email'
 * 
 * @return JSON - success status
 */
function label_sign_up() {

    // DATA JSON
    $json = $_POST['data'];

    $email = $json['email'];
    $password = $json['password'];
    $first_name = $json['first_name'];
    $last_name = $json['last_name'];
    $date_added = date('Y-m-d H:i:s');

// VALIDATION
if (!label_rexgex("email",$email)) { echo json_encode(array("status" => "345")); die; } // EMAIL FAILED VALIDATION

// ENCRYPT PASSWORD
$password = label_encrypt_password($password);

// WPDB
global $wpdb;
$table = $wpdb->prefix . "label_users";

// CHECK IF USER EXISTS FIRST
$qCheck = $wpdb->get_results("SELECT * FROM $table WHERE email = '$email' LIMIT 1");

if (count($qCheck) == 1) {
    echo json_encode(array("status" => "402"));
    die;
}

$wpdb->insert(
    $table, 
    array( 
        'email' => $email,
        'password' => $password,
        'first_name' => $first_name,
        'last_name' => $last_name,
        'last_updated' => $date_added,
        'date_added' => $date_added
    )
);

// GET USER ONCE SIGNUP FINISHES
$qFindUser = $wpdb->get_results("SELECT * FROM $table WHERE email = '$email' AND date_added = '$date_added' LIMIT 1");
foreach ($qFindUser as $user)
{
    $tmp_dict = array();
    $tmp_dict['first_name'] = $user->first_name;
    $tmp_dict['last_name'] = $user->last_name;
    $tmp_dict['email'] = $user->email;
    $tmp_dict['user_id'] = $user->id;
}

echo json_encode(array("status" => "205", "results" => $tmp_dict));

die;
}

/**
 * label_regex
 *
 * Creates a regex validation for a given regex type e.g. "password"
 * 
 * @return JSON - success status
 */ 
function label_rexgex($regex = "", $str = "") {
    if ($regex == "") { return false; }
    if ($str == "") { return false; } 

    switch ($regex) {
        case 'name':
        return preg_match("/^[A-z-,]$/", $str);
        case 'email':
        return (filter_var($str, FILTER_VALIDATE_EMAIL));
        case 'password':
        return preg_match("/^(((?=.*[a-z])(?=.*[A-Z]))((?=.*[a-z])(?=.*[0-9])))(?=.{6,})/", $str);
        default:
        return false;
        break;
    }
}

/**
 * label_get_details
 *
 * Gets details back from a given id
 * 
 * @return JSON - success status
 */ 
function label_get_details() {

    $json = $_POST['data'];

    $id = $json['user_id'];

    $user = get_userdata($id);
    
    $tmp_dict = array();
    $tmp_dict['first_name'] = $user->first_name;
    $tmp_dict['last_name'] = $user->last_name;
    $tmp_dict['email'] = $user->user_email;
    $tmp_dict['user_id'] = (string)$user->ID;

    // RETURN JSON
    label_echo_response("205", $tmp_dict);
}

/**
 * label_update_details
 *
 * Updates a users details for a given id passed into the function.
 *
 * @param Array - Containing 'id', 'first_name', 'last_name', 'email'
 * 
 * @return JSON - success status
 */ 
function label_update_details() {

    // DATA JSON
    $json = $_POST['data'];

    // WPDB
    global $wpdb;

    $id = $json['id'];
    $fn = $json['first_name'];
    $ln = $json['last_name'];
    $email = $json['email'];
    $last_updated = date('Y-m-d H:i:s');

    // CHECK IF EMAIL ALREADY EXISITS
    $user = get_user_by('id', $id);
    $exists = email_exists($email);
    if ($exists) 
    {
    	if ($exists != $id) {
    	 label_echo_response("408"); // FAILED EMAIL ALREADY IN USE
    	}
    } 

    update_user_meta($id, "first_name", $fn);
    update_user_meta($id, "last_name", $ln);

    $user_id = wp_update_user(array('ID' => $id, 'user_email' => $email));

    if (is_wp_error($user_id)) {
        label_echo_response();
    } else {
        label_echo_response("205");
    }
}

/**
 * label_update_password
 *
 * Updates a users password for an id
 *
 * @param Array - Containing 'id', 'new'
 * 
 * @return JSON - Success Status
 *
 */ 
function label_update_password() {

    $json = $_POST['data'];

    $id = $json['id'];
    $password = $json['new'];

    wp_set_password($password, $id);

    label_echo_response("205");
}

add_action('rest_api_init', function () {

    // SIGNUP

    register_rest_route('label/v1', '/signup/', array(
        'methods' => 'POST',
        'callback' => 'label_sign_up',
    ));

    // UPDATE PASSWORD

    register_rest_route('label/v1', '/upassword/', array(
        'methods' => 'POST',
        'callback' => 'label_update_password',
    ));

    // UPDATE DETAILS

    register_rest_route('label/v1', '/udetails/', array(
        'methods' => 'POST',
        'callback' => 'label_update_details',
    ));

    // GET DETAILS

    register_rest_route('label/v1', '/gdetails/', array(
        'methods' => 'POST',
        'callback' => 'label_get_details',
    ));

    // ADD META FOR USER

    register_rest_route('label/v1', '/imeta/', array(
        'methods' => 'POST',
        'callback' => 'label_set_meta',
    ));

});


/**
 * label_set_meta
 *
 * Sets user meta for key and user_id
 * 
 * @return JSON - status code/status
 */
function label_set_meta() {
    $data = $_POST['data'];

    $result = add_user_meta($data['user_id'], $data["key"], $data["meta"]);
    if ($result)
    {
        echo json_encode(array("status" => "205"));
    } else {
        echo json_encode(array("status" => "500"));
    }
}

/**
* label_encrypt_password
* 
* password_hash encryption for passwords
*
* @param $data String to encrypt
*
* @return String Hash of the password
*/
function label_encrypt_password($data) {
    return $hash = password_hash($data, PASSWORD_DEFAULT, ['cost' => 14]);
}

/**
* label_password_verify
* 
* Verify a password for hash
*
* @param $data String to verify
*
* @return Boolean
*/
function label_password_verify($password, $hash) {
    if (password_verify($password, $hash)) {
        return true;
    } else {
        return false;
    }
}

/**
 * label_echo_response
 *
 * echo a status response.
 *
 * @param String   $status  status code for the JSON response.
 * @param String   $result  result for the JSON response.
 * 
 * @return JSON - status code/status code with result
 */ 
function label_echo_response($status = "", $result = array()) {

    if ($status == "") {
        echo json_encode(array("status" => "405"));
    } else {
        if (count($result) == 0) {
            echo json_encode(array("status" => $status));
        } else {
            echo json_encode(array("status" => $status, "result" => $result));
        }
    }
    die;
}

/**
 * label_parse_json
 *
 * label_parse_json from request request for Label to sign up/register a new users account
 * 
 * @author Anthony Gordon <support@woosignal.com>
 *
 * @return JSON status e.g. {"status" : "205"}
 *
 */ 
function label_parse_json($status = "", $json = array()) {

    $response = json_decode($json, TRUE);

    if ($response['status'] == "205") {
        if (!empty($json)) {
            echoResponse($GLOBALS['responseSuccess'], $response['result']);
        } else {
            echoResponse($GLOBALS['responseSuccess']);
        }
    } else {
        echoResponse($GLOBALS['responseFailed']);
    }
    die;
}

/**
 * The code that runs during plugin deactivation.
 * This action is documented in includes/class-login-deactivator.php
 */
function label_deactivate_login() {
    require_once plugin_dir_path( __FILE__ ) . 'includes/class-login-deactivator.php';

    global $wpdb;

    Login_Deactivator::deactivate();
}

register_activation_hook( __FILE__, 'label_activate_login' );
register_deactivation_hook( __FILE__, 'label_deactivate_login' );

/**
 * The core plugin class that is used to define internationalization,
 * admin-specific hooks, and public-facing site hooks.
 */
require plugin_dir_path( __FILE__ ) . 'includes/class-login.php';

// ADD TO MENU

add_action('admin_menu', 'login_setup_menu');
 
function login_setup_menu(){
        add_menu_page( 'Label App', 'Label App', 'manage_options', 'label-app', 'label_app_init');
}

function label_app_init(){
    // WPDB
    global $wpdb;
    $table = $wpdb->prefix . "label_users";
        require_once 'label_screen.php';
}
