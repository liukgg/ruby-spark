module Spark
  module Helper
    module Statistic
      
      # Returns a sampling rate that guarantees a sample of size >= sampleSizeLowerBound 99.99% of
      # the time.
      #
      # === How the sampling rate is determined:
      # Let p = num / total, where num is the sample size and total is the total number of
      # datapoints in the RDD. We're trying to compute q > p such that
      #   - when sampling with replacement, we're drawing each datapoint with prob_i ~ Pois(q),
      #     where we want to guarantee Pr[s < num] < 0.0001 for s = sum(prob_i for i from 0 to total),
      #     i.e. the failure rate of not having a sufficiently large sample < 0.0001.
      #     Setting q = p + 5 * sqrt(p/total) is sufficient to guarantee 0.9999 success rate for
      #     num > 12, but we need a slightly larger q (9 empirically determined).
      #   - when sampling without replacement, we're drawing each datapoint with prob_i
      #     ~ Binomial(total, fraction) and our choice of q guarantees 1-delta, or 0.9999 success
      #     rate, where success rate is defined the same as in sampling with replacement.
      #
      def compute_fraction(lower_bound, total, with_replacement)
        lower_bound = lower_bound.to_f

        if with_replacement
          upper_poisson_bound(lower_bound) / total
        else
          fraction = lower_bound / total
          upper_binomial_bound(0.00001, total, fraction)
        end
      end

      def upper_poisson_bound(bound)
        num_std = if bound < 6
          12
        elsif bound < 16
          9
        else
          6
        end.to_f

        [bound + num_std * Math.sqrt(bound), 1e-10].max
      end

      def upper_binomial_bound(delta, total, fraction)
        gamma = -Math.log(delta) / total
        [1, fraction + gamma + Math.sqrt(gamma*gamma + 2*gamma*fraction)].min
      end

    end
  end
end
