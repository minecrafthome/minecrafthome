#!/usr/bin/env php
<?php
require_once("../inc/util_ops.inc");

$badges = BoincBadge::enum("");

foreach ($badges as $badge) {
    $type = $badge->type?"team":"user";

    if ($type == "user") {
        $items = BoincUser::enum(null, "where $badge->sql_rule");
    } else {
        $items = BoincTeam::enum(null, "where $badge->sql_rule");
    }

    foreach ($items as $item) {
        echo "Assigning $badge->name to $type $item->id \n";
        assign_badge($badge->type?False:True, $item, $badge);
    }
}

?>
