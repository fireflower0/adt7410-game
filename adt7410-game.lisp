;; Load packages
(load "packages.lisp" :external-format :utf-8)

(in-package :cl-cffi)

;; Load wrapper API
(load "libwiringPi.lisp" :external-format :utf-8)

;; I2C device address (0x48)
(defconstant +i2c-addr+ #X48)

;; i2cの初期設定
(defvar *fd* (wiringPiI2CSetup +i2c-addr+))

(defun byte-swap (num-value)
  (let (str-value temp-msb temp-lsb)
    ;; 数値を文字列へ変換
    (setq str-value (write-to-string num-value :base 16))
    ;; 上位２桁(MSB)を取得
    (setq temp-msb (subseq str-value 0 2))
    ;; 下位２桁(LSB)を取得
    (setq temp-lsb (subseq str-value 2))
    ;; スワップして結合
    (setq str-value (concatenate 'string temp-lsb temp-msb))
    ;; 文字列を数値へ変換
    (parse-integer str-value :radix 16)))

(defun adt7410 ()
  (let (base-data actual-data)
    ;; 温度を16ビットのデータで取得するようレジスタ「0x03」に設定
    (wiringPiI2CWriteReg8 *fd* #X03 #X80)
    ;; ADT7410からデータを取得
    (setq base-data (wiringPiI2CReadReg16 *fd* #X00))
    ;; バイトスワップ
    (setq actual-data (byte-swap base-data))
    ;; 温度計算
    (* actual-data 0.0078)))

(defun main () 
  (sdl:with-init ()
    (sdl:window 640 480 :title-caption "ADT7410")
    (setf (sdl:frame-rate) 60)
    (sdl:initialise-default-font sdl:*font-10x20*) ; フォント初期化

    (sdl:update-display)

    (sdl:with-events ()
      (:quit-event () t)
      (:key-down-event (:key key)
        (when (sdl:key= key :sdl-key-escape)
              (sdl:push-quit-event)))
      (:idle ()
        ;; 描画する前に前に書いたものを消します
        (sdl:clear-display sdl:*black*)
        ;; 四角形を描画
        (sdl:draw-box-* 50 ; 左上頂点のX座標
                        380  ; 左上頂点のY座標
                        540 ; 幅
                        60  ; 高さ
                        :color sdl:*magenta* ; 中の色
                        :stroke-color sdl:*white*) ; 辺の色
        ;; 文字列描画
        (sdl:draw-string-solid-* (format nil "The current temperature is ~d degrees" (adt7410))
                                 100  ; 左上頂点のX座標
                                 400) ; 左上頂点のY座標
        (sdl:update-display)))))

(main)
