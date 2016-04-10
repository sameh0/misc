$ID=1; 
include "scripts/DB.php";
$RST=18;
 $sql = 'INSERT INTO spec (';
    foreach($_POST as $key => $value) {
  $sql.=$key.",";
    }
    $sql.='Quan '; $sql=substr($sql,0,-1).') VALUES (';
    foreach($_POST as $key => $value) {
    $sql.=':'.trim($key).',';
    }
    $sql.=':Quan ';
    $sql=substr($sql,0,-1).')';
    $N=$RST;
    $stmt = $dbh->prepare ($sql);
     foreach($_POST as $key => $value) {
    $Value=trim(urldecode($value));
    $stmt -> bindParam(':'.$key.'',$Value);
    }
    $stmt -> bindParam(':Quan',$N);
     try {
    $stmt -> execute();
    echo "New record created successfully , Quan".$RST;
        }    catch(PDOException $e)        {
        echo $sql . "
" . $e->getMessage();
        $i=0;
        $myfile = fopen("wew.txt", "a")or die("Unable to open file!");
     fwrite($myfile, $e->getMessage());  }
  $conn = null;
   ?>
