<?php
//excel
if($_FILES['file']){
    $partinfo = pathinfo($_FILES['file']['name']);
    if(in_array($partinfo['extension'], array('csv'))){
      $handle = fopen($_FILES['file']['tmp_name'],"r");
      setlocale(LC_ALL, 'zh_CN');
      while($data = fgetcsv($handle, 1000, ",")){
        $tag = ''; $data[2] = iconv('GBK', 'UTF-8', $data[2]);
        if(strpos($data[2], '日本转运到中国')!==false || strpos($data[2], '日亚转运到中国')!==fals){
          $tag = '日转转运费';
        }elseif(strpos($data[2], '日亚代购现货')!==false){
          $tag = '五式充值费';
        }
        if(is_numeric(trim($data[0])) && strlen($data[0])>=12 && $tag){
          $data[5] = strtr($data[5], array('('=>'', ')'=>''));
          $tparr = explode(' ', $data[5]);
          $row[0] = iconv('GBK', 'UTF-8', trim($tparr[1]));
          $row[1] = iconv('GBK', 'UTF-8', trim($tparr[0]));
          $row[2] = $data[1];
          $row[3] = $data[4];
          $row[4] = $data[6];
          $row[5] = '';
          $row[6] = '其他收入';
          $row[7] = $tag;
          $rows[] = $row; unset($row);
        }
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
    header( 'Content-Disposition: attachment;filename=淘宝支付流水账'.date('YmdHis').'.csv');
    $fp = fopen('php://output', 'w');
    fputcsv($fp, array('对方支付宝账号', '真实姓名', '交易流水号', '交易时间', '交易金额', '收支类型', '收支名称', '备注'));
    foreach ($rows as $v) {
        fputcsv($fp, $v);
    }
    fclose($fp);
    exit;
}
?>