<?php
//excel
if($_FILES['file']){
    $partinfo = pathinfo($_FILES['file']['name']);
    if(in_array($partinfo['extension'], array('csv'))){
      $handle = fopen($_FILES['file']['tmp_name'],"r");
      setlocale(LC_ALL, 'zh_CN');
      while($data = fgetcsv($handle, 1000, ",")){
        $tag = ''; $data[2] = iconv('GBK', 'UTF-8', $data[2]);
      }
      fclose($handle);
    }
    //phpexcel
    date_default_timezone_set('Asia/Shanghai');
    include '../Classes/PHPExcel.php';
    $objPHPExcel = new PHPExcel();
    $objPHPExcel->getProperties()->setCreator("zhong qing")
            ->setLastModifiedBy("zhong qing")
            ->setTitle("Office 2007 XLSX Test Document")
            ->setSubject("Office 2007 XLSX Test Document")
            ->setDescription("Test document for Office 2007 XLSX, generated using PHP classes.")
            ->setKeywords("office 2007 openxml php")
            ->setCategory("Test result file");
    $letter = array('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z');
    foreach ($rows as $k => $v) {
      $i = $k+2;
      $newobj = $objPHPExcel->setActiveSheetIndex(0);
      $objPHPExcel->setActiveSheetIndex(0)->setCellValue("A1", "对方支付宝账号");
      $objPHPExcel->setActiveSheetIndex(0)->setCellValue("B1", "真实姓名");
      $objPHPExcel->setActiveSheetIndex(0)->setCellValue("C1", "交易流水号");
      $objPHPExcel->setActiveSheetIndex(0)->setCellValue("D1", "交易时间");
      $objPHPExcel->setActiveSheetIndex(0)->setCellValue("E1", "交易金额");
      $objPHPExcel->setActiveSheetIndex(0)->setCellValue("F1", "收支类型");
      $objPHPExcel->setActiveSheetIndex(0)->setCellValue("G1", "收支名称");
      $objPHPExcel->setActiveSheetIndex(0)->setCellValue("H1", "备注");
      foreach ($v as $ke => $va) {
        $index = $letter[$ke].$i;
        if($ke==3){
          $objPHPExcel->setActiveSheetIndex(0)->setCellValue($index, PHPExcel_Shared_Date::PHPToExcel($va));
          $objActSheet = $objPHPExcel->getActiveSheet();
          $objActSheet->getStyle($index)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_DATE_YYYYMMDD2);
        }else
          $objPHPExcel->setActiveSheetIndex(0)->setCellValue($index, $va);
      }
    }
    $objPHPExcel->getActiveSheet()->setTitle(date('Y-m-d',time()));
    $objPHPExcel->setActiveSheetIndex(0);
    ob_end_clean();
    header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    header('Content-Disposition: attachment;filename="淘宝支付流水账'.date('YmdHis').'.xls"');
    header('Cache-Control: max-age=0');
    $objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel5');
    $objWriter->save('php://output');

    //excel
    ob_end_clean(); 
    $fileName='淘宝支付流水账'.date('Ymdhis',time());
    header("Content-Disposition: attachment;filename=$fileName.xls");
    header('Cache-Control: max-age=0');
    header("Content-Type: application/vnd.ms-excel; charset=UTF-8");
    $str="对方支付宝账号\t真实姓名\t交易流水号\t交易时间\t交易金额\t收支类型\t收支名称\t备注\n";
    echo iconv('UTF-8','gbk', $str);
    foreach ($rows as $v) {
      echo iconv('UTF-8', 'gbk', $v[0])."\t".iconv('UTF-8', 'gbk', $v[1])."\t".$v[2]."\t".$v[3]."\t".$v[4]."\t".iconv('UTF-8', 'gbk', $v[5])."\t".iconv('UTF-8', 'gbk', $v[6])."\t".iconv('UTF-8', 'gbk', $v[7])."\n";
    }

    //cvs
    header( 'Content-Type: text/csv' );
    header( 'Content-Disposition: attachment;filename=集装箱数据'.date('YmdHis').'.csv');
    $fp = fopen('php://output', 'w');
    fputcsv($fp, array('对方支付宝账号', '真实姓名', '交易流水号', '交易时间', '交易金额', '收支类型', '收支名称', '备注'));
    foreach ($rows as $v) {
        fputcsv($fp, $v);
    }
    fclose($fp);
    exit;
}

if($_FILES['file']){
  $partinfo = pathinfo($_FILES['file']['name']);
  if(in_array($partinfo['extension'], array('xls'))){
      require(INC_PATH.'/PHPExcel/Classes/PHPExcel.php');
      require(INC_PATH.'/PHPExcel/Classes/PHPExcel/IOFactory.php');
      require(INC_PATH.'/PHPExcel/Classes/PHPExcel/Reader/Excel5.php');
      // $objReader = PHPExcel_IOFactory::createReader('Excel5');
      $objPHPExcel = PHPExcel_IOFactory::load($_FILES['ifile']['tmp_name']);
      // $objPHPExcel = $objReader->load($_FILES['file']['tmp_name']);
      $objWorksheet = $objPHPExcel->getActiveSheet();
      $highestRow = $objWorksheet->getHighestRow(); 
      $highestColumn = $objWorksheet->getHighestColumn();
      $highestColumnIndex = PHPExcel_Cell::columnIndexFromString($highestColumn);
      $data = array();
      $date = '0'; $mdate = date('Y-m-d');
      $fields = array('date', 'abstract', 'subject', 'income', 'expenditure', 'balance', 'document_no');
      for ($row = 1; $row <= $highestRow; $row++){
          if($row <= 2) continue;
          for ($col = 0;$col < $highestColumnIndex;$col++){
              if($col >= 8) break;
              $arr = $objWorksheet->getCellByColumnAndRow($col, $row)->getCalculatedValue();
              if(!$arr && $col==0) break;
              if($col==0){
                  $rp = array('.'=>'-');
                  $arr = strtr($arr, $rp);
                  $date = max($date, date('Y-m-d', strtotime($arr)));
                  $mdate = min($mdate, date('Y-m-d', strtotime($arr)));
              }
              if($col==1){
                  $coord = $objWorksheet->getCellByColumnAndRow($col, $row)->getCoordinate();
                  $abstract1 = $objWorksheet->getComment($coord)->getText()->getPlainText();
                  // if($abstract1){
                  //     pr('乱码');
                  //     pr($abstract1);
                  //     pr($objWorksheet->getCellByColumnAndRow($col, $row));die;
                  // }
                  $data[$row-3][$fields[$col].'1'] = $abstract1;
              }
              $data[$row-3][$fields[$col]] = $arr;
          }
      }
      $days = ceil((strtotime($date) - strtotime($mdate))/86400);
  }else{
      exit('<script>alert("请上传正确的表格文件"); window.history.back(); </script>');
  }

setlocale(LC_ALL, "en_US.UTF-8");
setlocale(LC_ALL, 'zh_CN');

//代理IP
$url = 'http://31f.cn/area/%E7%BE%8E%E5%9B%BD/';
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_USERAGENT, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
curl_setopt($ch, CURLOPT_TIMEOUT, 20);
$contents = curl_exec($ch);
if(curl_errno($ch)){
    echo curl_error($ch)."\r\n"; die;
}
curl_close($ch);
preg_match_all('/<td>([\d\.]+)<\/td>[^<]+<td>(\d+)</', $contents, $matches);

$zipfile = ROOT_PATH.'/data/tmp.zip';
    if(file_exists($zipfile)) unlink($zipfile);
    $zip = new ZipArchive();
    if ($zip->open($zipfile, ZipArchive::CREATE)===TRUE) {
      foreach ($dataarray as $v) {
        $v['cardf'] = trim($v['cardf']);
        if(file_exists($v['cardf'])) {
          $zip->addFile($v['cardf']);
        }
      }
      $zip->close();
    }else{
      die('ZIP文件创建失败');
    }
    if(file_exists($zipfile)){
      header('Content-Description: File Transfer');
        header('Content-Type: application/octet-stream');
        header('Content-Disposition: attachment; filename='.basename($zipfile));
        header('Content-Transfer-Encoding: binary');
        header('Expires: 0');
        header('Cache-Control: must-revalidate');
        header('Pragma: public');
        header('Content-Length: ' . filesize($zipfile));
        ob_clean();
        flush();
        readfile($zipfile);
        exit;
    }else{
      die('文件压缩创建失败');
    }

// 周日期
$fstime = mktime(0,0,0,date('m', $etime), date('d', $etime)-date('w', $etime)+1-$i*7, date('Y', $etime)); 
$fetime = mktime(23,59,59,date('m', $etime), date('d', $etime)-date('w', $etime)+7-$i*7, date('Y', $etime));

//月份
$sdate = date('Y-m-d H:i:s');
$nextMonth = date('Y-m', strtotime('last day of +'.$num.' month', strtotime($sdate)));
$edate = date('d', strtotime($sdate)) > date('t', strtotime($nextMonth)) ?  date('Y-m-t h:i:s', strtotime('last day of +'.$num.' month', strtotime($sdate))) : date('Y-m-d H:i:s', strtotime('+'.$num.' month', strtotime($sdate)));

// 开立方根
exp(1/3*log($avolume);

// curl ssl error
export NSS_STRICT_NOFORK=DISABLED;

    /**
     * 随机分配红包
     *
     * @param integer $totalBonus 总红包金额
     * @param integer $totalNum 红包数量
     * @param integer $sendedBonus 已发送金额
     * @param integer $sendedNum 已发送份数
     * @param integer $rdMin 随机下限
     * @param integer $rdMax 随机上限
     * @param float $bigRate
     * @return void
     */
    function randomBonusWithSpecifyBound(int $totalBonus, int $totalNum, float $sendedBonus, int $sendedNum, float $rdMin, float $rdMax) {
      $minBonus = max(0.01, $rdMin); //最小金额
      $yeBonus = round($totalBonus - $sendedBonus, 2);
      $yeNum = $totalNum - $sendedNum;
      if($totalNum - 1 > $sendedNum){
          if($yeBonus <= $rdMin) return $yeBonus;
          $maxBonus = $rdMax > 0 ? round(min($rdMax, $yeBonus / $yeNum * 2), 2) : round($yeBonus / $yeNum * 2, 2);
          return $maxBonus <= $minBonus ? $minBonus : rand($minBonus * 100, $maxBonus * 100) / 100;
      }else{
          if($yeBonus <= $rdMax)
              return max(0, $yeBonus);
          else
              return $rdMax;
      }
  }
?>