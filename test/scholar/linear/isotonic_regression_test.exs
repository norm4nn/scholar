defmodule Scholar.Linear.IsotonicRegressionTest do
  use Scholar.Case, async: true
  alias Scholar.Linear.IsotonicRegression
  doctest IsotonicRegression

  def y do
    Nx.tensor(
      [-6.0, 31.65735903, 68.93061443, 86.31471806, 97.47189562] ++
        [48.58797346, 130.29550745, 74.97207708, 95.86122887, 152.12925465] ++
        [139.89476364, 162.24533249, 166.24746787, 93.95286648, 143.40251006] ++
        [153.62943611, 130.6606672, 181.51858789, 143.22194896, 187.78661368] ++
        [183.22612189, 141.55212267, 131.7747108, 185.90269152, 182.94379124] ++
        [121.9048269, 134.7918433, 196.61022551, 187.3647915, 199.05986908] ++
        [168.69936022, 187.28679514, 206.82537807, 225.31802623, 215.76740307] ++
        [178.17594692, 159.54589563, 150.87930799, 152.17808231, 148.44397271] ++
        [174.67860334, 168.88348091, 203.06000578, 148.2094817, 197.33312449] ++
        [173.43206982, 173.50738009, 217.56005055, 167.59101491, 180.60115027] ++
        [221.59128164, 202.56218593, 176.51459568, 183.44920233, 150.36665926] ++
        [151.26758454, 188.15256339, 206.02215053, 158.8768722, 192.71722811] ++
        [172.54369321, 235.35671925, 161.15673632, 199.94415417, 216.71936349] ++
        [190.4827371, 161.23463097, 225.97538526, 202.70532523, 219.4247621] ++
        [198.13399385, 174.83330595, 210.52297206, 247.20325466, 256.87440568] ++
        [166.53666701, 181.19027109, 266.83544133, 221.47239262, 181.10133173] ++
        [211.72245773, 254.33596236, 245.94203039, 239.54083994, 178.13256282] ++
        [240.71736481, 220.29540593, 176.86684072, 250.43181849, 226.99048352] ++
        [253.54297533, 191.08942885, 196.62997466, 276.16473911, 235.69384458] ++
        [201.21740957, 257.73554893, 192.24837393, 264.75599251, 228.2585093]
    )
  end

  describe "fit" do
    test "fit - all defaults" do
      n = 100
      x = Nx.iota({n})

      y = y()

      model = IsotonicRegression.fit(x, y)
      assert model.x_min == Nx.tensor(0.0)
      assert model.x_max == Nx.tensor(99.0)
      assert model.x_thresholds == Nx.iota({100}, type: :f32)

      assert_all_close(
        model.y_thresholds,
        Nx.tensor(
          [-6.0, 31.657358169555664, 68.93061065673828, 77.45819854736328] ++
            [77.45819854736328, 77.45819854736328, 100.37627410888672, 100.37627410888672] ++
            [100.37627410888672, 142.77029418945312, 142.77029418945312, 142.77029418945312] ++
            [142.77029418945312, 142.77029418945312, 142.77029418945312, 142.77029418945312] ++
            [142.77029418945312, 159.4623260498047, 159.4623260498047, 159.4623260498047] ++
            [159.4623260498047, 159.4623260498047, 159.4623260498047, 159.4623260498047] ++
            [159.4623260498047, 159.4623260498047, 159.4623260498047, 180.6462860107422] ++
            [180.6462860107422, 180.6462860107422, 180.6462860107422, 180.646286010742] ++
            [180.6462860107422, 180.6462860107422, 180.6462860107422, 180.6462860107422] ++
            [180.6462860107422, 180.6462860107422, 180.6462860107422, 180.6462860107422] ++
            [180.6462860107422, 180.6462860107422, 180.6462860107422, 180.6462860107422] ++
            [181.4241943359375, 181.4241943359375, 181.4241943359375, 183.5004119873047] ++
            [183.5004119873047, 183.5004119873047, 183.5004119873047, 183.5004119873047] ++
            [183.5004119873047, 183.5004119873047, 183.5004119873047, 183.5004119873047] ++
            [183.66250610351562, 183.66250610351562, 183.66250610351562, 183.66250610351562] ++
            [183.66250610351562, 194.1490478515625, 194.1490478515625, 194.1490478515625] ++
            [194.1490478515625, 194.1490478515625, 194.1490478515625, 204.21456909179688] ++
            [204.21456909179688, 204.21456909179688, 204.21456909179688, 204.21456909179688] ++
            [210.52296447753906, 212.95114135742188, 212.95114135742188, 212.95114135742188] ++
            [212.95114135742188, 220.2829132080078, 220.2829132080078, 220.2829132080078] ++
            [220.2829132080078, 222.26158142089844, 222.26158142089844, 222.26158142089844] ++
            [222.26158142089844, 222.26158142089844, 222.26158142089844, 222.26158142089844] ++
            [223.7369384765625, 223.7369384765625, 223.7369384765625, 223.7369384765625] ++
            [223.7369384765625, 232.61196899414062, 232.61196899414062, 232.61196899414062] ++
            [232.61196899414062, 232.61196899414062, 246.5072479248047, 246.5072479248047]
        )
      )

      assert model.increasing == Nx.u8(1)
      assert model.cutoff_index == Nx.tensor(99)
      assert model.preprocess == {}
    end

    test "fit with sample_weights" do
      x = Nx.tensor([2.0, 2.0, 3.0, 4.0, 5.0])
      y = Nx.tensor([2.0, 3.0, 7.0, 8.0, 9.0])
      sample_weights = Nx.tensor([1, 3, 2, 7, 4])
      model = IsotonicRegression.fit(x, y, sample_weights: sample_weights)
      assert model.x_min == Nx.tensor(2.0)
      assert model.x_max == Nx.tensor(5.0)
      assert model.x_thresholds == Nx.tensor([2.0, 3.0, 4.0, 5.0, 0.0])
      assert_all_close(model.y_thresholds, Nx.tensor([2.75, 7.0, 8.0, 9.0, 0]))

      assert model.increasing == Nx.u8(1)
      assert model.cutoff_index == Nx.tensor(3)
      assert model.preprocess == {}
    end

    test "fit column target" do
      x = Nx.tensor([2.0, 2.0, 3.0, 4.0, 5.0])
      y = Nx.tensor([2.0, 3.0, 7.0, 8.0, 9.0])
      sample_weights = Nx.tensor([1, 3, 2, 7, 4])
      model = IsotonicRegression.fit(x, y, sample_weights: sample_weights)
      col_model = IsotonicRegression.fit(x, y |> Nx.new_axis(-1), sample_weights: sample_weights)
      assert model == col_model
    end

    test "fit 2 column target raises" do
      x = Nx.tensor([2.0, 2.0, 3.0, 4.0, 5.0])
      y = Nx.tensor([2.0, 3.0, 7.0, 8.0, 9.0])
      y = Nx.new_axis(y, -1)
      y = Nx.concatenate([y, y], axis: 1)
      sample_weights = Nx.tensor([1, 3, 2, 7, 4])

      message =
        "Scholar.Linear.IsotonicRegression expected y to have shape {n_samples}, got tensor with shape: #{inspect(Nx.shape(y))}"

      assert_raise ArgumentError,
                   message,
                   fn ->
                     IsotonicRegression.fit(x, y, sample_weights: sample_weights)
                   end
    end

    test "fit with sample_weights and :increasing? set to false" do
      x = Nx.tensor([2.0, 2.0, 3.0, 4.0, 5.0, 5.0, 6.0])
      y = Nx.tensor([11, 12, 9, 7, 5, 4, 2])
      sample_weights = Nx.tensor([1, 3, 2, 7, 4, 2, 1])

      model =
        Scholar.Linear.IsotonicRegression.fit(x, y,
          sample_weights: sample_weights,
          increasing: false
        )

      assert model.x_min == Nx.tensor(2.0)
      assert model.x_max == Nx.tensor(6.0)
      assert model.x_thresholds == Nx.tensor([2.0, 3.0, 4.0, 5.0, 6.0, 0.0, 0.0])

      assert_all_close(
        model.y_thresholds,
        Nx.tensor([11.75, 9.0, 7.0, 4.666666507720947, 2.0, 0.0, 0.0])
      )

      assert model.increasing == Nx.u8(0)
      assert model.cutoff_index == Nx.tensor(4)
      assert model.preprocess == {}
    end

    test "fit with sample_weights and :increasing? as default (:auto)" do
      x = Nx.tensor([2.0, 2.0, 3.0, 4.0, 5.0, 5.0, 6.0])
      y = Nx.tensor([11, 12, 9, 7, 5, 4, 2])
      sample_weights = Nx.tensor([1, 3, 2, 7, 4, 2, 1])

      model = Scholar.Linear.IsotonicRegression.fit(x, y, sample_weights: sample_weights)
      assert model.increasing == Nx.u8(0)
    end
  end

  test "preprocess" do
    n = 100
    x = Nx.iota({n})

    y = y()

    model = IsotonicRegression.fit(x, y)
    model = IsotonicRegression.preprocess(model)

    assert model.x_thresholds ==
             Nx.tensor(
               [0.0, 1.0, 2.0, 3.0, 5.0, 6.0] ++
                 [8.0, 9.0, 16.0, 17.0, 26.0, 27.0] ++
                 [43.0, 44.0, 46.0, 47.0, 55.0, 56.0] ++
                 [60.0, 61.0, 66.0, 67.0, 71.0, 72.0] ++
                 [73.0, 76.0, 77.0, 80.0, 81.0, 87.0] ++
                 [88.0, 92.0, 93.0, 97.0, 98.0, 99.0]
             )

    assert_all_close(
      model.y_thresholds,
      Nx.tensor(
        [-6.0, 31.657358169555664, 68.93061065673828, 77.45819854736328] ++
          [77.45819854736328, 100.37627410888672, 100.37627410888672, 142.77029418945312] ++
          [142.77029418945312, 159.4623260498047, 159.4623260498047, 180.6462860107422] ++
          [180.6462860107422, 181.4241943359375, 181.4241943359375, 183.5004119873047] ++
          [183.5004119873047, 183.66250610351562, 183.66250610351562, 194.1490478515625] ++
          [194.1490478515625, 204.21456909179688, 204.21456909179688, 210.52296447753906] ++
          [212.95114135742188, 212.95114135742188, 220.2829132080078, 220.2829132080078] ++
          [222.26158142089844, 222.26158142089844, 223.7369384765625, 223.7369384765625] ++
          [232.61196899414062, 232.61196899414062, 246.5072479248047, 246.5072479248047]
      )
    )

    assert_all_close(
      model.preprocess.coefficients,
      Nx.tensor([
        [37.65735626220703, -6.0],
        [37.27325439453125, -5.615896224975586],
        [8.527587890625, 51.87543487548828],
        [0.0, 77.45819854736328],
        [22.918075561523438, -37.132179260253906],
        [0.0, 100.37627410888672],
        [42.394020080566406, -238.77587890625],
        [0.0, 142.77029418945312],
        [16.692031860351562, -124.30221557617188],
        [0.0, 159.4623260498047],
        [21.1839599609375, -391.32061767578125],
        [0.0, 180.6462860107422],
        [0.7779083251953125, 147.19622802734375],
        [0.0, 181.4241943359375],
        [2.0762176513671875, 85.91818237304688],
        [0.0, 183.5004119873047],
        [0.1620941162109375, 174.58523559570312],
        [0.0, 183.66250610351562],
        [10.486541748046875, -445.5299987792969],
        [0.0, 194.1490478515625],
        [10.065521240234375, -470.17535400390625],
        [0.0, 204.21456909179688],
        [6.3083953857421875, -243.68148803710938],
        [2.4281768798828125, 35.69422912597656],
        [0.0, 212.95114135742188],
        [7.3317718505859375, -344.2635192871094],
        [0.0, 220.2829132080078],
        [1.978668212890625, 61.98945617675781],
        [0.0, 222.26158142089844],
        [1.4753570556640625, 93.905517578125],
        [0.0, 223.7369384765625],
        [8.875030517578125, -592.765869140625],
        [0.0, 232.61196899414062],
        [13.895278930664062, -1115.2301025390625],
        [0.0, 246.5072479248047]
      ])
    )

    assert_all_close(
      model.preprocess.x,
      Nx.tensor(
        [0.0, 1.0, 2.0, 3.0, 5.0, 6.0] ++
          [8.0, 9.0, 16.0, 17.0, 26.0, 27.0] ++
          [43.0, 44.0, 46.0, 47.0, 55.0, 56.0] ++
          [60.0, 61.0, 66.0, 67.0, 71.0, 72.0] ++
          [73.0, 76.0, 77.0, 80.0, 81.0, 87.0] ++
          [88.0, 92.0, 93.0, 97.0, 98.0, 99.0]
      )
    )
  end

  test "predict" do
    n = 100
    x = Nx.iota({n})

    y = y()

    model = IsotonicRegression.fit(x, y)
    model = IsotonicRegression.preprocess(model)
    x_to_predict = Nx.tensor([34.64, 23.64, 46.93])

    assert_all_close(
      IsotonicRegression.predict(model, x_to_predict),
      Nx.tensor([180.6462860107422, 159.4623260498047, 183.35507202148438])
    )
  end
end
